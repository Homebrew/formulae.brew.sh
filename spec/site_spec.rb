# frozen_string_literal: true

require "fileutils"
require "jekyll"
require "json"
require "tmpdir"

RSpec.describe "Site build" do
  it "derives the public package tag index from the unsigned internal package files" do
    Dir.mktmpdir("package-tag-index-") do |directory|
      %w[
        api/internal/packages.arm64_sequoia.json api/internal/packages.new_tag.json
        api/internal/packages.signed_only.jws.json api/internal/packages.backup.txt api/packages.unrelated.json
      ].each do |path|
        FileUtils.mkdir_p(File.dirname("#{directory}/#{path}"))
        File.write("#{directory}/#{path}", "{}")
      end
      FileUtils.cp(File.expand_path("../api/internal-package-tags.json", __dir__), "#{directory}/api/")

      Jekyll::Site.new(Jekyll.configuration(
                         "config"      => File.expand_path("../_config.yml", __dir__),
                         "source"      => directory,
                         "destination" => "#{directory}/_site",
                         "quiet"       => true,
                       )).process

      expect(JSON.parse(File.read("#{directory}/_site/api/internal-package-tags.json")))
        .to eq(%w[arm64_sequoia new_tag])
    end
  end

  it "publishes API files without publishing downloaded build archives" do
    Dir.mktmpdir("site-build-") do |directory|
      %w[data-core/data-core.tar.gz data-cask/data-cask.tar.gz api/internal/executables.txt].each do |path|
        FileUtils.mkdir_p(File.dirname("#{directory}/#{path}"))
        File.write("#{directory}/#{path}", "contents")
      end

      Jekyll::Site.new(Jekyll.configuration(
                         "config"      => File.expand_path("../_config.yml", __dir__),
                         "source"      => directory,
                         "destination" => "#{directory}/_site",
                         "quiet"       => true,
                       )).process

      expect(File.read("#{directory}/_site/api/internal/executables.txt")).to eq("contents")
      expect(Dir.glob("#{directory}/_site/data-*/*")).to be_empty
    end
  end
end
