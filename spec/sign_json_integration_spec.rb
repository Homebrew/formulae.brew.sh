# frozen_string_literal: true

require "base64"
require "fileutils"
require "json"
require "open3"
require "openssl"
require "rspec"
require "tmpdir"
require "yaml"

RSpec.describe "Bundled API JSON signing" do
  let(:repository_root) { Pathname(__dir__).parent }
  let(:source_site) { @fixture_root/"site" }
  let(:temporary_parent) { @fixture_root/"temporary" }
  let(:inputs) do
    {
      "formula.json"                => "[ {\"name\":\"café\"} ]\n",
      "cask.json"                   => "[{\"token\":\"example\"}]\n",
      "formula_tap_migrations.json" => "{\"old\":\"new/tap\"}\n",
      "cask_tap_migrations.json"    => "{}\n",
      "internal/formula_names.json" => "[\"café\"]\n",
      "advisories.json"             => "[]\n",
    }
  end

  around do |example|
    Dir.mktmpdir("api-signing-inputs-") do |directory|
      @fixture_root = Pathname(directory)
      example.run
    end
  end

  before do
    temporary_parent.mkpath
    inputs.each do |name, payload|
      path = source_site/"api"/name
      path.dirname.mkpath
      path.write(payload)
    end
  end

  def verify_built_api(site, temporary_parent: nil)
    api = site/"api"
    raise "Expected an unsigned API" unless api.glob("**/*.jws.json").empty?

    paths = %w[formula.json cask.json formula_tap_migrations.json cask_tap_migrations.json]
            .map { |name| api/name }
    paths.concat((api/"internal").glob("*.json"))
    payloads = paths.to_h { |path| [path.relative_path_from(api).to_s, path.read] }

    # The signer resolves its root from __dir__. Copy its inputs, never sign the upload tree in place.
    Dir.mktmpdir("api-signing-integration-", temporary_parent) do |directory|
      root = Pathname(directory)
      (root/"script/jws").mkpath
      FileUtils.cp(repository_root/"script/sign-json.rb", root/"script/sign-json.rb")
      key = OpenSSL::PKey::RSA.new(2048)
      (root/"script/jws/ci-test.pem").write(key.public_key.to_pem)
      payloads.each do |name, payload|
        path = root/"_site/api"/name
        path.dirname.mkpath
        path.write(payload)
      end
      if (api/"advisories.json").file?
        (root/"_site/api/advisories.json").write((api/"advisories.json").read)
      end

      # The disposable private key exists only in memory and this subprocess's environment.
      _stdout, stderr, status = Open3.capture3(
        {
          "BUNDLE_GEMFILE"     => (repository_root/"Gemfile").to_s,
          "JWS_SIGNING_KEY_ID" => "ci-test",
          "JWS_SIGNING_KEY"    => key.to_pem,
        },
        "bundle", "exec", "script/sign-json.rb",
        chdir: root
      )
      raise "API signing failed: #{stderr}" unless status.success?

      signed_api = root/"_site/api"
      # This checks the copied input set, not signing exclusions for API paths outside that set.
      expected_paths = paths.map { |path| path.relative_path_from(api).sub_ext(".jws.json") }
      expect(signed_api.glob("**/*.jws.json").map { |path| path.relative_path_from(signed_api) })
        .to match_array(expected_paths)
      payloads.each do |name, payload|
        document = JSON.parse((signed_api/name).sub_ext(".jws.json").read)
        expect(document.fetch("payload")).to eq(payload)
        expect(document.fetch("signatures").length).to eq(1)
        signature = document.fetch("signatures").first
        expect(signature.fetch("header").fetch("kid")).to eq("ci-test")
        expect(JSON.parse(Base64.urlsafe_decode64(signature.fetch("protected")))).to eq(
          { "alg" => "PS512", "b64" => false, "crit" => ["b64"] },
        )
        valid_signature = key.public_key.verify_pss(
          "SHA512",
          Base64.urlsafe_decode64(signature.fetch("signature")),
          "#{signature.fetch("protected")}.#{payload}",
          salt_length: :digest,
          mgf1_hash:   "SHA512",
        )
        expect(valid_signature).to be(true)
        expect((api/name).read).to eq(payload)
      end
      expect(api.glob("**/*.jws.json")).to be_empty
    end
  end

  it "runs the bundled signer without changing the source API or production pin and discards all output" do
    pin = repository_root/"script/jws/homebrew-1.pem"
    original_pin = pin.read
    verify_built_api(source_site, temporary_parent:)
    expect(temporary_parent.children).to be_empty
    inputs.each { |name, payload| expect((source_site/"api"/name).read).to eq(payload) }
    expect(pin.read).to eq(original_pin)
  end

  it "configures CI to run the generated API integration test" do
    workflow = YAML.safe_load_file(repository_root/".github/workflows/tests.yml")
    step = workflow.fetch("jobs").fetch("build").fetch("steps")
                   .find { |candidate| candidate["name"] == "Test generated site" }
    expect(step).not_to be_nil
    expect(step.fetch("run")).to eq("bundle exec rspec --exclude-pattern spec/formula_feeds_spec.rb")
    expect(step.fetch("env", {})).to include("API_SIGNING_TEST_SITE" => "_site")
  end

  # The signer's internal/*.json glob also matches signatures; reject them instead of signing them again.
  it "rejects an already signed source API" do
    (source_site/"api/internal/formula_names.jws.json").write("{}")
    expect { verify_built_api(source_site, temporary_parent:) }
      .to raise_error(RuntimeError, "Expected an unsigned API")
    expect(temporary_parent.children).to be_empty
  end

  # CI opts in after building the site. A missing or invalid site must fail, not fall back to fixtures.
  if ENV.key?("API_SIGNING_TEST_SITE")
    it "signs and verifies the generated API using only a disposable key and copy" do
      verify_built_api(Pathname(ENV.fetch("API_SIGNING_TEST_SITE")).expand_path)
    end
  end
end
