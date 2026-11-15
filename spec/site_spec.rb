# frozen_string_literal: true

require "fileutils"
require "jekyll"
require "tmpdir"

RSpec.describe "Site build" do
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
