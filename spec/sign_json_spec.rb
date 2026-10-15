# frozen_string_literal: true

require "base64"
require "fileutils"
require "json"
require "open3"
require "openssl"
require "pathname"
require "rbconfig"
require "rspec"
require "tmpdir"
require "yaml"

RSpec.describe "API JSON signing" do
  let(:repository_root) { Pathname(__dir__).parent }
  let(:root) { Pathname(Dir.mktmpdir("api-signing-")) }
  let(:signing_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:inputs) do
    {
      "formula.json"                => "[ {\"name\":\"café\"} ]\n",
      "cask.json"                   => "[{\"token\":\"example\"}]\n",
      "formula_tap_migrations.json" => "{\"old\":\"new/tap\"}\n",
      "cask_tap_migrations.json"    => "{}\n",
      "internal/formula_names.json" => "[\"café\"]\n",
      "internal/cask_names.json"    => "[\"example\"]\n",
    }
  end

  before do
    (root/"script/jws").mkpath
    FileUtils.cp(repository_root/"script/sign-json.rb", root/"script/sign-json.rb")
    (root/"script/jws/homebrew-1.pem").write(signing_key.public_key.to_pem)
    inputs.each do |name, contents|
      path = root/"_site/api"/name
      path.dirname.mkpath
      path.write(contents)
    end
  end

  after do
    FileUtils.remove_entry(root)
  end

  def sign(key: signing_key.to_pem, key_id: "homebrew-1", prelude: nil)
    command = [RbConfig.ruby]
    command += ["-e", "#{prelude}\nload ARGV.fetch(0)"] if prelude
    command << (root/"script/sign-json.rb").to_s
    Open3.capture3(
      { "JWS_SIGNING_KEY_ID" => key_id, "JWS_SIGNING_KEY" => key },
      *command,
      chdir: root,
    )
  end

  it "signs all expected files and preserves exact payload bytes" do
    # advisories.json is published unsigned.
    (root/"_site/api/advisories.json").write("[]\n")
    _stdout, stderr, status = sign
    expect(status).to be_success, stderr

    signed_paths = (root/"_site/api").glob("**/*.jws.json")
    expect(signed_paths.length).to eq(inputs.length)
    inputs.each do |name, payload|
      document = JSON.parse((root/"_site/api"/name).sub_ext(".jws.json").read)
      expect(document.fetch("payload")).to eq(payload)
      expect(document.fetch("signatures").length).to eq(1)
      signature = document.fetch("signatures").first
      expect(signature.fetch("header").fetch("kid")).to eq("homebrew-1")
      expect(JSON.parse(Base64.urlsafe_decode64(signature.fetch("protected")))).to eq(
        { "alg" => "PS512", "b64" => false, "crit" => ["b64"] },
      )
      expect(signing_key.public_key.verify_pss(
        "SHA512",
        Base64.urlsafe_decode64(signature.fetch("signature")),
        "#{signature.fetch("protected")}.#{payload}",
        salt_length: :digest,
        mgf1_hash:   "SHA512",
      )).to be(true)
    end
    expect(root/"_site/api/advisories.jws.json").not_to exist
  end

  it "fails before writing signatures when the key is missing" do
    _stdout, _stderr, status = sign(key: nil)
    expect(status).not_to be_success
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  it "rejects a signing key that does not match the pinned public key" do
    _stdout, stderr, status = sign(key: OpenSSL::PKey::RSA.new(2048).to_pem)
    expect(status).not_to be_success
    expect(stderr).to include("Signing key does not match pinned public key")
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  it "fails before writing signatures when the pinned public key is missing" do
    (root/"script/jws/homebrew-1.pem").unlink
    _stdout, stderr, status = sign
    expect(status).not_to be_success
    expect(stderr).to include("Missing pinned public key")
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  it "rejects a pinned public key that cannot be parsed" do
    (root/"script/jws/homebrew-1.pem").write("not a public key\n")
    _stdout, stderr, status = sign
    expect(status).not_to be_success
    expect(stderr).to include("Unable to load pinned public key")
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  it "rejects a pin containing a private key" do
    (root/"script/jws/homebrew-1.pem").write(signing_key.to_pem)
    _stdout, stderr, status = sign
    expect(status).not_to be_success
    expect(stderr).to include("contains a private key")
    expect(stderr).not_to include(signing_key.to_pem)
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  it "rejects an encrypted private key alongside the pinned public key" do
    encrypted_key = signing_key.private_to_pem(OpenSSL::Cipher.new("aes-256-cbc"), "fixture-password")
    (root/"script/jws/homebrew-1.pem").write(signing_key.public_key.to_pem + encrypted_key)
    _stdout, stderr, status = sign
    expect(status).not_to be_success
    expect(stderr).to include("contains a private key")
    expect(stderr).not_to include("Enter PEM pass phrase", encrypted_key)
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  ["../homebrew-1", "homebrew-1\n", "HOMEBREW-1"].each do |key_id|
    it "rejects the invalid key ID #{key_id.inspect}" do
      _stdout, stderr, status = sign(key_id:)
      expect(status).not_to be_success
      expect(stderr).to include("Invalid JWS signing key ID")
      expect((root/"_site").glob("**/*.jws.json")).to be_empty
    end
  end

  it "pins the expected public key for the deployment's signing key ID" do
    workflow = YAML.safe_load_file(repository_root/".github/workflows/tests.yml")
    signing_step = workflow.fetch("jobs").fetch("deploy").fetch("steps")
                           .find { |step| step.fetch("env", {}).key?("JWS_SIGNING_KEY_ID") }
    expect(signing_step).not_to be_nil
    key_id = signing_step.fetch("env").fetch("JWS_SIGNING_KEY_ID")
    expect(key_id).to match(/\A[a-z0-9-]+\z/)
    path = repository_root/"script/jws/#{key_id}.pem"
    expect(path).to exist
    public_key = OpenSSL::PKey::RSA.new(path.read)
    expect(public_key).not_to be_private
    expect(OpenSSL::Digest::SHA256.hexdigest(public_key.public_to_der)).to eq(
      "f73fb42960f2948890dfcc9ff2b964dff5d1771269207ff766f642baabcf0cbb",
    )
  end

  it "restores, signs and repackages the unsigned artifact" do
    (root/"unsigned-site").mkpath
    _stdout, stderr, status = Open3.capture3(
      "tar", "-cf", "unsigned-site/artifact.tar", "-C", "_site", ".", chdir: root,
    )
    expect(status).to be_success, stderr
    FileUtils.remove_entry(root/"_site")

    workflow = YAML.safe_load_file(repository_root/".github/workflows/tests.yml")
    restore = workflow.fetch("jobs").fetch("deploy").fetch("steps")
                      .find { |step| step["name"] == "Restore unsigned site" }.fetch("run")
    _stdout, stderr, status = Open3.capture3("bash", "-e", "-c", restore, chdir: root)
    expect(status).to be_success, stderr
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
    _stdout, stderr, status = sign
    expect(status).to be_success, stderr

    _stdout, stderr, status = Open3.capture3("tar", "-cf", "signed.tar", "-C", "_site", ".", chdir: root)
    expect(status).to be_success, stderr
    (root/"published").mkpath
    _stdout, stderr, status = Open3.capture3("tar", "-xf", "signed.tar", "-C", "published", chdir: root)
    expect(status).to be_success, stderr
    inputs.each do |name, payload|
      expect((root/"published/api"/name).read).to eq(payload)
      document = JSON.parse((root/"published/api"/name).sub_ext(".jws.json").read)
      expect(document.fetch("payload")).to eq(payload)
    end
  end

  it "does not sign invalid JSON" do
    (root/"_site/api/formula.json").write("not JSON")
    _stdout, _stderr, status = sign
    expect(status).not_to be_success
    expect((root/"_site").glob("**/*.jws.json")).to be_empty
  end

  it "fails verification when a signature is invalid" do
    _stdout, stderr, status = sign(prelude: <<~RUBY)
      require "openssl"
      class OpenSSL::PKey::RSA
        def sign_pss(*)
          "invalid signature"
        end
      end
    RUBY
    expect(status).not_to be_success
    expect(stderr).to include("invalid API signature or payload")
  end

  it "fails verification when the signed payload changes on disk" do
    _stdout, stderr, status = sign(prelude: <<~RUBY)
      require "json"
      require "pathname"
      module CorruptSignedPayload
        def write(contents, *)
          if to_s.end_with?(".jws.json")
            document = JSON.parse(contents)
            document["payload"] = "[]"
            contents = document.to_json
          end
          super(contents)
        end
      end
      Pathname.prepend(CorruptSignedPayload)
    RUBY
    expect(status).not_to be_success
    expect(stderr).to include("invalid API signature or payload")
  end
end
