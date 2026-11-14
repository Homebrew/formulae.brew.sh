# frozen_string_literal: true

require "fileutils"
require "jekyll"
require "json"
require "nokogiri"
require "open3"
require "rspec"
require "tmpdir"
require "yaml"

RSpec.describe "Parallel formula feed publication" do
  let(:project) { Pathname(__dir__).parent }
  let(:workflow) { YAML.safe_load_file(project/".github/workflows/tests.yml") }
  let(:core_steps) { workflow.fetch("jobs").fetch("generate-core").fetch("steps") }
  let(:feed_job) { workflow.fetch("jobs").fetch("generate-feeds") }
  let(:steps) { feed_job.fetch("steps") }
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

  def run_step(name)
    script = steps.find { |step| step["name"] == name }.fetch("run")
    Open3.capture3(
      {
        "RUNNER_TEMP" => (@root/"temporary").to_s,
        "PATH"        => "#{@root}/bin:#{ENV.fetch("PATH")}",
      },
      "bash", "--noprofile", "--norc", "-e", "-o", "pipefail", "-c", script,
      chdir: @root
    )
  end

  def stub_brew(script)
    (@root/"bin").mkpath
    (@root/"bin/brew").write <<~SH
      #!/bin/bash
      if [[ "$1" == --repo ]]; then
        printf '%s' "$PWD/tap"
        exit 0
      fi
      #{script}
    SH
    (@root/"bin/git").write("#!/bin/bash\necho false\n")
    FileUtils.chmod(0755, [@root/"bin/brew", @root/"bin/git"])
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

  it "fetches full history only in the independent feed job" do
    workflow.fetch("jobs").each_value do |job|
      job.fetch("steps").each do |step|
        next unless step.fetch("uses", "").start_with?("Homebrew/actions/setup-homebrew@")

        %w[core cask].each { |tap| expect(step.fetch("with").fetch(tap)).to eq(false).or eq("shallow") }
      end
    end
    expect(core_steps.none? { |step| step.fetch("name", "").include?("feeds") }).to be(true)
    expect(feed_job).not_to have_key("needs")
    expect(steps.find { |step| step["id"] == "feeds" }.fetch("run")).to include("--unshallow")
  end

  it "uses the same post-cleanup compression tools when restoring and saving feeds" do
    cleanup = steps.index { |step| step["run"] == "brew test-bot --only-cleanup-before" }
    expect(cleanup).not_to be_nil
    steps.each_with_index do |step, index|
      next if step.dig("with", "path") != "_data/formula_feeds.json"

      expect(index).to be > cleanup
    end
  end

  it "retains cached feeds after a failed command writes a partial replacement" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.pretty_generate(cached))
    original = feed_path.read
    stub_brew <<~SH
      printf '{' > "$RUNNER_TEMP/formula_feeds.json"
      exit 1
    SH

    _stdout, _stderr, generation = run_step("Generate formula feeds")
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

  it "fails when neither generation nor a cache supplies feeds" do
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

  it "accepts a validated cached snapshot as a fallback" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))
    stdout, stderr, status = run_step("Validate formula feeds")
    expect(status).to be_success, stderr
    expect(stdout).not_to include("::warning::")
    expect(JSON.parse(feed_path.read)).to eq(cached)
  end

  it "validates generated or cached feeds before building and deploying" do
    fallback = steps.find { |step| step["name"] == "Validate formula feeds" }
    expect(fallback["continue-on-error"]).not_to be(true)
    expect(steps.index(fallback)).to be > steps.index { |step| step["name"] == "Generate formula feeds" }
    jobs = workflow.fetch("jobs")
    expect(jobs.fetch("build").fetch("needs")).to include("generate-core", "generate-feeds")
    expect(jobs.fetch("deploy-issue").fetch("needs")).to include("generate-feeds")
    expect(jobs.fetch("deploy").fetch("needs")).to eq("build")
    built_tests = jobs.fetch("build").fetch("steps").find { |step| step["name"] == "Test generated site" }
    expect(built_tests.fetch("run")).to eq("bundle exec rspec")
    save = steps.find { |step| step["name"] == "Save formula feeds" }
    expect(save.fetch("if")).to eq("github.ref == 'refs/heads/main' && steps.feeds.outcome == 'success'")
  end

  it "bounds fetching and generation together before falling back to cached feeds" do
    generation = steps.find { |step| step["id"] == "feeds" }
    expect(generation).not_to have_key("if")
    expect(generation.fetch("run")).to include("--unshallow", "brew generate-formula-feeds")
    expect(generation.fetch("timeout-minutes")).to eq(5)
    expect(steps.index(generation)).to be > steps.index { |step| step["name"] == "Restore formula feeds" }
    expect(generation.fetch("continue-on-error")).to be(true)
    warning = steps.find { |step| step["name"] == "Report cached fallback" }
    expect(warning.fetch("if")).to eq("steps.feeds.outcome != 'success'")
    expect(steps.index(warning)).to be > steps.index { |step| step["name"] == "Validate formula feeds" }
  end

  it "retains usable cached feeds when fetching full history fails" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))
    stub_brew("touch generation-ran")
    (@root/"bin/git").write <<~SH
      #!/bin/bash
      if [[ "$3" == rev-parse ]]; then
        echo true
      else
        echo 'History fetch failed' >&2
        exit 1
      fi
    SH

    _stdout, stderr, status = run_step("Generate formula feeds")
    expect(status).not_to be_success
    expect(stderr).to include("History fetch failed")
    expect(@root/"generation-ran").not_to exist
    expect(run_step("Validate formula feeds").last).to be_success
    expect(JSON.parse(feed_path.read)).to eq(cached)
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
    stub_brew <<~SH
      printf '{"new": [], "updated": []}' > "$RUNNER_TEMP/formula_feeds.json"
    SH

    expect(run_step("Generate formula feeds").last).not_to be_success
    expect(feed_path.read).to eq(original)
    expect(run_step("Validate formula feeds").last).to be_success
  end

  %w[absent invalid valid].each do |cache_state|
    it "generates fresh validated feeds when the cache is #{cache_state}" do
      if cache_state != "absent"
        feed_path.dirname.mkpath
        feed_path.write((cache_state == "valid") ? JSON.generate(cached.merge("revision" => "old")) : "{invalid")
      end
      (@root/"generated.json").write(JSON.generate(cached))
      stub_brew('cp generated.json "$RUNNER_TEMP/formula_feeds.json"')

      _stdout, stderr, status = run_step("Generate formula feeds")

      expect(status).to be_success, stderr
      expect(JSON.parse(feed_path.read)).to eq(cached)
      expect(run_step("Validate formula feeds").last).to be_success
    end
  end

  it "archives core data without depending on feed generation" do
    archive = core_steps.find { |step| step["name"] == "Archive data" }.fetch("run")
    paths = %w[
      _data/formula/ _data/formula_canonical.json
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
      "_data/analytics/security/current.json", "api/analytics/security/current.json",
      "api/internal/executables.txt"
    )
  end

  it "passes the selected feed snapshot to the build in its own artifact" do
    feed_path.dirname.mkpath
    feed_path.write(JSON.generate(cached))
    _stdout, stderr, status = run_step("Archive data")
    expect(status).to be_success, stderr
    FileUtils.rm(feed_path)

    upload = steps.find { |step| step.fetch("uses", "").start_with?("actions/upload-artifact@") }.fetch("with")
    expect(upload.fetch("name")).to eq("data-feeds")
    expect(upload.fetch("path")).to eq("data-feeds.tar.gz")
    (@root/"data-feeds").mkpath
    FileUtils.mv(@root/"data-feeds.tar.gz", @root/"data-feeds")
    extraction = workflow.fetch("jobs").fetch("build").fetch("steps")
                         .find { |step| step["name"] == "Move artifacts into place" }.fetch("run")
                         .lines.find { |line| line.include?("data-feeds/") }
    expect(extraction).not_to be_nil
    _stdout, stderr, status = Open3.capture3("bash", "-e", "-c", extraction, chdir: @root)
    expect(status).to be_success, stderr
    expect(JSON.parse(feed_path.read)).to eq(cached)
  end
end
