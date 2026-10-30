# frozen_string_literal: true

require "fileutils"
require "jekyll"
require "json"
require "nokogiri"
require "open3"
require "rspec"
require "tmpdir"
require "yaml"

RSpec.describe "Formula feed workflow fallback" do
  let(:project) { Pathname(__dir__).parent }
  let(:workflow) { YAML.safe_load_file(project/".github/workflows/tests.yml") }
  let(:core_job) { workflow.fetch("jobs").fetch("generate-core") }
  let(:steps) { core_job.fetch("steps") }
  let(:feed_path) { @root/"_data/formula_feeds.json" }
  let(:cached) do
    { "new" => 50, "updated" => 500 }.to_h do |type, count|
      [type, Array.new(count) do |index|
        { "id" => "#{type}:#{index}", "name" => "example-#{index}", "date" => "2026-01-01T00:00:00Z",
          "commit" => "a" * 40, "versions" => ["1.0"] }
      end]
    end
  end

  around do |example|
    Dir.mktmpdir("formula-feed-fallback-") do |directory|
      @root = Pathname(directory)
      (@root/"temporary").mkpath
      example.run
    end
  end

  def run_step(id, outcome: "failure")
    script = steps.find { |step| step["id"] == id }.fetch("run")
    Open3.capture3(
      {
        "GITHUB_OUTPUT"           => (@root/"outputs").to_s,
        "RUNNER_TEMP"             => (@root/"temporary").to_s,
        "FEED_GENERATION_OUTCOME" => outcome,
        "FEED_TEST_CORE"          => (@root/"core").to_s,
        "PATH"                    => "#{@root}/bin:#{ENV.fetch("PATH")}",
      },
      "bash", "--noprofile", "--norc", "-e", "-o", "pipefail", "-c", script,
      chdir: @root
    )
  end

  def render_feeds
    FileUtils.cp_r(project/"feeds", @root/"feeds")
    (@root/"_layouts").mkpath
    FileUtils.cp(project/"_layouts/formula_feed.xml", @root/"_layouts/formula_feed.xml")
    Jekyll::Site.new(Jekyll.configuration(
                       "source" => @root.to_s, "destination" => (@root/"_site").to_s,
                       "url" => "https://formulae.brew.sh", "quiet" => true
                     )).process
    %w[new updated].to_h do |type|
      [type, Nokogiri::XML((@root/"_site/feeds/formula-#{type}.xml").read) { |config| config.strict.nonet }]
    end
  end

  it "retains cached feeds after a failed command writes a partial replacement" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.pretty_generate(cached))
    original = feed_path.read
    (@root/"bin").mkpath
    (@root/"core").mkpath
    _stdout, stderr, status = Open3.capture3("git", "init", "--quiet", (@root/"core").to_s)
    expect(status).to be_success, stderr
    (@root/"bin/brew").write <<~SH
      #!/bin/bash
      if [[ "$1" == --repo ]]; then
        printf '%s\n' "$FEED_TEST_CORE"
      else
        printf '{' > "$RUNNER_TEMP/formula_feeds.json"
        exit 1
      fi
    SH
    FileUtils.chmod(0755, @root/"bin/brew")

    _stdout, _stderr, generation = run_step("formula-feeds")
    expect(generation).not_to be_success
    expect(feed_path.read).to eq(original)
    stdout, stderr, fallback = run_step("formula-feeds-fallback")
    expect(fallback).to be_success, stderr
    expect(stdout).to include("::warning::", "retaining the last successful feeds")
    expect((@root/"outputs").read).to eq("available=true\n")
    expect(feed_path.read).to eq(original)
    render_feeds.each do |type, xml|
      expect(xml.xpath("//item/guid").map(&:text)).to eq(cached.fetch(type).map { |entry| entry.fetch("id") })
      expect(xml.xpath("//item/pubDate").map(&:text).uniq).to eq(["Thu, 01 Jan 2026 00:00:00 +0000"])
    end
  end

  it "publishes valid empty feeds when generation fails without a cache" do
    stdout, stderr, status = run_step("formula-feeds-fallback")
    expect(status).to be_success, stderr
    expect(stdout).to include("::warning::", "publishing empty feeds")
    expect((@root/"outputs").read).to eq("available=false\n")
    expect(JSON.parse(feed_path.read)).to eq({ "new" => [], "updated" => [] })
    render_feeds.each_value do |xml|
      expect(xml.xpath("/rss/channel").length).to eq(1)
      expect(xml.xpath("//item")).to be_empty
      expect(xml.xpath("//lastBuildDate")).to be_empty
    end
  end

  it "discards an invalid cache without blocking the site" do
    feed_path.dirname.mkpath
    feed_path.write("{invalid")
    _stdout, stderr, status = run_step("formula-feeds-fallback")
    expect(status).to be_success, stderr
    expect(JSON.parse(feed_path.read)).to eq({ "new" => [], "updated" => [] })
    expect((@root/"outputs").read).to eq("available=false\n")
  end

  it "keeps fresh feeds without a fallback warning" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))
    stdout, stderr, status = run_step("formula-feeds-fallback", outcome: "success")
    expect(status).to be_success, stderr
    expect(stdout).not_to include("::warning::")
    expect((@root/"outputs").read).to eq("available=true\n")
    expect(JSON.parse(feed_path.read)).to eq(cached)
  end

  it "keeps generator failures and command tests outside the deployment gate" do
    generation = steps.find { |step| step["id"] == "formula-feeds" }
    expect(generation.fetch("continue-on-error")).to be(true)
    expect(generation.fetch("timeout-minutes")).to be <= 3
    jobs = workflow.fetch("jobs")
    expect(jobs.fetch("build").fetch("needs")).not_to include("test-formula-feeds")
    expect(jobs.fetch("deploy").fetch("needs")).to eq("build")
    expect(jobs.fetch("test-formula-feeds").fetch("steps").last.fetch("run"))
      .to eq("bundle exec rspec spec/formula_feeds_spec.rb")
    built_tests = jobs.fetch("build").fetch("steps").find { |step| step["name"] == "Test generated site" }
    expect(built_tests.fetch("run")).to include("--exclude-pattern spec/formula_feeds_spec.rb")
    expect(built_tests.fetch("env").fetch("FORMULA_FEEDS_AVAILABLE"))
      .to eq("${{ needs.generate-core.outputs.formula-feeds-available }}")
    save = steps.find { |step| step["name"] == "Save formula feeds" }
    expect(save.fetch("if")).to eq("steps.formula-feeds.outcome == 'success' && github.ref == 'refs/heads/main'")
  end
end
