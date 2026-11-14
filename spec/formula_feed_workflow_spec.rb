# frozen_string_literal: true

require "fileutils"
require "jekyll"
require "json"
require "nokogiri"
require "open3"
require "rspec"
require "tmpdir"
require "yaml"

RSpec.describe "Cached formula feed publication" do
  let(:project) { Pathname(__dir__).parent }
  let(:workflow) { YAML.safe_load_file(project/".github/workflows/tests.yml") }
  let(:core_job) { workflow.fetch("jobs").fetch("generate-core") }
  let(:steps) { core_job.fetch("steps") }
  let(:refresh_steps) do
    YAML.safe_load_file(project/".github/workflows/feeds.yml").fetch("jobs").fetch("refresh").fetch("steps")
  end
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
      (@root/"script").mkpath
      FileUtils.cp(project/"script/validate-feeds.rb", @root/"script")
      example.run
    end
  end

  def run_step(name, from: steps)
    script = from.find { |step| step["name"] == name }.fetch("run")
    Open3.capture3(
      {
        "RUNNER_TEMP" => (@root/"temporary").to_s,
        "PATH"        => "#{@root}/bin:#{ENV.fetch("PATH")}",
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

  it "keeps full tap history out of regular publication" do
    workflow.fetch("jobs").each_value do |job|
      job.fetch("steps").each do |step|
        next unless step.fetch("uses", "").start_with?("Homebrew/actions/setup-homebrew@")

        %w[core cask].each { |tap| expect(step.fetch("with").fetch(tap)).to eq(false).or eq("shallow") }
      end
    end
    expect(steps.none? { |step| step.fetch("run", "").include?("generate-formula-feeds") }).to be(true)
    setup = refresh_steps.find { |step| step["name"] == "Set up Homebrew" }
    expect(setup.fetch("with").fetch("core")).to be(true)
  end

  it "uses the same post-cleanup compression tools when restoring and saving feeds" do
    [steps, refresh_steps].each do |job_steps|
      cleanup = job_steps.index { |step| step["run"] == "brew test-bot --only-cleanup-before" }
      expect(cleanup).not_to be_nil
      expect(job_steps.index { |step| step.dig("with", "path") == "_data/formula_feeds.json" }).to be > cleanup
    end
  end

  it "retains cached feeds after a failed command writes a partial replacement" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.pretty_generate(cached))
    original = feed_path.read
    (@root/"bin").mkpath
    (@root/"bin/brew").write <<~SH
      #!/bin/bash
      printf '{' > "$RUNNER_TEMP/formula_feeds.json"
      exit 1
    SH
    FileUtils.chmod(0755, @root/"bin/brew")

    _stdout, _stderr, generation = run_step("Generate formula feeds", from: refresh_steps)
    expect(generation).not_to be_success
    expect(feed_path.read).to eq(original)
    _stdout, stderr, fallback = run_step("Validate formula feeds")
    expect(fallback).to be_success, stderr
    expect(feed_path.read).to eq(original)
    render_feeds.each do |type, xml|
      expect(xml.xpath("//item/guid").map(&:text)).to eq(cached.fetch(type).map { |entry| entry.fetch("id") })
      expect(xml.xpath("//item/pubDate").map(&:text).uniq).to eq(["Thu, 01 Jan 2026 00:00:00 +0000"])
    end
  end

  it "fails without a cache rather than fetching full history" do
    _stdout, _stderr, status = run_step("Validate formula feeds")
    expect(status).not_to be_success
    expect(feed_path).not_to exist
  end

  it "fails without replacing an invalid cache" do
    feed_path.dirname.mkpath
    feed_path.write("{invalid")
    _stdout, _stderr, status = run_step("Validate formula feeds")
    expect(status).not_to be_success
    expect(feed_path.read).to eq("{invalid")
  end

  it "fails when cached feeds are empty" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate({ "new" => [], "updated" => [] }))
    _stdout, _stderr, status = run_step("Validate formula feeds")
    expect(status).not_to be_success
  end

  it "publishes the last validated feeds unchanged while they refresh separately" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))
    stdout, stderr, status = run_step("Validate formula feeds")
    expect(status).to be_success, stderr
    expect(stdout).not_to include("::warning::")
    expect(JSON.parse(feed_path.read)).to eq(cached)
  end

  it "requires cached feeds to validate before generating, building and deploying" do
    fallback = steps.find { |step| step["name"] == "Validate formula feeds" }
    expect(fallback["continue-on-error"]).not_to be(true)
    expect(steps.index(fallback)).to be < steps.index { |step| step["run"] == "brew generate-formula-api" }
    jobs = workflow.fetch("jobs")
    expect(jobs.fetch("build").fetch("needs")).to include("generate-core")
    expect(jobs.fetch("deploy").fetch("needs")).to eq("build")
    built_tests = jobs.fetch("build").fetch("steps").find { |step| step["name"] == "Test generated site" }
    expect(built_tests.fetch("run")).to eq("bundle exec rspec")
    expect(steps.none? { |step| step["name"] == "Save formula feeds" }).to be(true)
    save = refresh_steps.find { |step| step["name"] == "Save formula feeds" }
    expect(save.fetch("if")).to eq("github.ref == 'refs/heads/main'")
  end

  it "rejects duplicate entry identifiers before they can be cached" do
    cached.fetch("new")[1]["id"] = cached.fetch("new")[0].fetch("id")
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))

    expect(run_step("Validate formula feeds").last).not_to be_success
  end

  it "rejects invalid entry dates before they can be cached" do
    cached.fetch("updated")[0]["date"] = "invalid"
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))

    expect(run_step("Validate formula feeds").last).not_to be_success
  end

  it "rejects invalid successful generation without replacing previous feeds" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))
    original = feed_path.read
    (@root/"bin").mkpath
    (@root/"bin/brew").write <<~SH
      #!/bin/bash
      printf '{"new": [], "updated": []}' > "$RUNNER_TEMP/formula_feeds.json"
    SH
    FileUtils.chmod(0755, @root/"bin/brew")

    expect(run_step("Generate formula feeds", from: refresh_steps).last).not_to be_success
    expect(feed_path.read).to eq(original)
  end

  it "makes complete validated output available for caching" do
    (@root/"generated.json").write(JSON.generate(cached))
    (@root/"bin").mkpath
    (@root/"bin/brew").write("#!/bin/bash\ncp generated.json \"$RUNNER_TEMP/formula_feeds.json\"\n")
    FileUtils.chmod(0755, @root/"bin/brew")

    _stdout, stderr, status = run_step("Generate formula feeds", from: refresh_steps)

    expect(status).to be_success, stderr
    expect(JSON.parse(feed_path.read)).to eq(cached)
  end

  it "archives both feed data and security analytics for the site build" do
    archive = steps.find { |step| step["name"] == "Archive data" }.fetch("run")
    paths = %w[
      _data/formula/ _data/formula_canonical.json _data/formula_feeds.json
      api/formula/ api/formula_tap_migrations.json api/internal/formula.names.json formula/
      api/internal/executables.txt
      _data/analytics/security/current.json api/analytics/security/current.json
    ]
    paths.each do |path|
      destination = @root/path
      if path.end_with?("/")
        destination.mkpath
      else
        destination.dirname.mkpath
        destination.write("{}")
      end
    end

    _stdout, stderr, status = Open3.capture3("bash", "-e", "-c", archive, chdir: @root)
    expect(status).to be_success, stderr
    contents, stderr, status = Open3.capture3("tar", "tzf", "data-core.tar.gz", chdir: @root)
    expect(status).to be_success, stderr
    expect(contents.lines.map(&:strip)).to include(
      "_data/formula_feeds.json", "_data/analytics/security/current.json", "api/analytics/security/current.json",
      "api/internal/executables.txt"
    )
  end
end
