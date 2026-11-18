# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "rbconfig"
require "tmpdir"
require "uri"

RSpec.describe "Published package freshness" do
  let(:root) { Pathname(Dir.mktmpdir("package fixtures #%")) }

  before { (root/"internal").mkpath }
  after { FileUtils.remove_entry(root) }

  def package(tag, generated_at, metadata_first: true)
    metadata = { "bottle_tag" => tag, "generated_at" => generated_at }
    payload = { "formulae" => { "sample" => "x" * 4096 } }
    payload = metadata_first ? { "metadata" => metadata }.merge(payload) : payload.merge("metadata" => metadata)
    (root/"internal/packages.#{tag}.jws.json").write(JSON.generate("payload" => JSON.generate(payload)))
  end

  def check(*tags, path: ENV.fetch("PATH"))
    (root/"internal-package-tags.json").write(JSON.generate(tags))
    encoded_path = root.to_s.split("/").map { |part| URI.encode_uri_component(part) }.join("/")
    api_url = URI::File.build(path: "#{encoded_path}/").to_s
    Open3.capture2e(
      { "GITHUB_OUTPUT" => (root/"output").to_s, "PATH" => path },
      RbConfig.ruby, File.expand_path("../script/check-published-packages.rb", __dir__), api_url,
      chdir: root
    )
  end

  it "lists only public files more than an hour old in the issue" do
    now = Time.now.to_i
    package("arm64_sequoia", now - (61 * 60))
    package("arm64_linux", now - (59 * 60))

    log, status = check("arm64_sequoia", "arm64_linux")
    expect(status).not_to be_success
    expect(log).to include("arm64_sequoia")
    expect((root/"output").read.chomp).to eq("failed_packages=packages.arm64_sequoia.jws.json")
  end

  it "accepts recent files and reads metadata beyond the initial byte range" do
    package("arm64_sequoia", Time.now.to_i - (15 * 60))
    package("sonoma", Time.now.to_i, metadata_first: false)
    log, status = check("arm64_sequoia", "sonoma")
    expect(status).to be_success, log
  end

  it "reports a stale generation when a nested timestamp is recent" do
    (root/"internal/packages.sonoma.jws.json").write(JSON.generate(
      "payload" => JSON.generate("metadata" => { "previous" => { "generated_at" => Time.now.to_i }, "generated_at" => 100 }),
    ))

    log, status = check("sonoma")
    expect(status).not_to be_success
    expect(log).to include("generated at 1970-01-01T00:01:40Z")
    expect((root/"output").read.chomp).to eq("failed_packages=packages.sonoma.jws.json")
  end

  it "fetches the full payload if the range request fails" do
    package("sonoma", Time.now.to_i)
    curl = root/"curl"
    curl.write <<~SH
      #!/bin/sh
      for arg do
        if [ "$arg" = --range ]; then
          exit 22
        fi
      done
      case "$arg" in
        */internal-package-tags.json) cat internal-package-tags.json ;;
        *) cat internal/packages.sonoma.jws.json ;;
      esac
    SH
    curl.chmod(0o755)

    log, status = check("sonoma", path: "#{root}:#{ENV.fetch("PATH")}")
    expect(status).to be_success, log
  end

  it "reads a timestamp from a range that ends midway through a UTF-8 character" do
    package("sonoma", Time.now.to_i)
    signed = root/"internal/packages.sonoma.jws.json"
    body = signed.read
    body[1023] = "é"
    signed.write(body)

    log, status = check("sonoma")
    expect(status).to be_success, log
  end

  it "names a public file with unreadable metadata in the issue" do
    (root/"internal/packages.sequoia.jws.json").write("null")

    _log, status = check("sequoia")
    expect(status).not_to be_success
    expect((root/"output").read.chomp).to eq("failed_packages=packages.sequoia.jws.json")
  end

  it "reports a missing public file" do
    _log, status = check("sonoma")
    expect(status).not_to be_success
    expect((root/"output").read.chomp).to eq("failed_packages=packages.sonoma.jws.json")
  end

  it "fails if the public tag index contains no tags" do
    log, status = check
    expect(status).not_to be_success
    expect(log).to include("Invalid package tag index")
  end
end
