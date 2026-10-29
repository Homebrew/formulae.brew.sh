# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "open3"
require "time"
require "tmpdir"
require "yaml"

RSpec.describe "Analytics workflow validation" do
  let(:repository) { File.expand_path("..", __dir__) }
  let(:steps) do
    YAML.safe_load_file("#{repository}/.github/workflows/tests.yml").fetch("jobs").fetch("generate-analytics")
        .fetch("steps")
  end
  let(:validation) { steps.find { |step| step["name"] == "Validate analytics data" }.fetch("run") }

  around do |example|
    Dir.mktmpdir("analytics-validation-") do |directory|
      @root = Pathname(directory)
      example.run
    end
  end

  before do
    (@root/"script").mkpath
    FileUtils.cp("#{repository}/script/prune-analytics.rb", @root/"script")
    %w[_data api].each do |prefix|
      (@root/prefix/"analytics/install").mkpath
      (@root/prefix/"analytics/install/30d.json").write(JSON.generate(
                                                          "start_date" => (Time.now.utc.to_date - 30).iso8601,
                                                          "end_date"   => Time.now.utc.to_date.iso8601,
                                                        ))
    end
  end

  def validate
    Open3.capture3(
      "bash", "-euo", "pipefail", "-c", validation, chdir: @root
    )
  end

  def write_new_reports
    %w[_data api].each do |prefix|
      %w[github-packages/30d github/history releases/history formula-history/history].each do |report|
        path = @root/prefix/"analytics/#{report}.json"
        path.dirname.mkpath
        path.write(JSON.generate(
                     if report == "github-packages/30d"
                       { "formulae" => { "wget" => { "fetched_at" => Time.now.utc.iso8601 } } }
                     else
                       { "rows" => [] }
                     end,
                   ))
      end
    end
  end

  it "rejects snapshots containing only legacy usage reports" do
    _stdout, _stderr, status = validate

    expect(status).not_to be_success
  end

  it "preserves all reports in a complete snapshot" do
    write_new_reports

    _stdout, stderr, status = validate

    expect(status).to be_success, stderr
    %w[_data api].each do |prefix|
      expect(@root/prefix/"analytics/github/history.json").to exist
    end
  end

  it "rejects an absent snapshot" do
    FileUtils.rm_rf([@root/"_data/analytics", @root/"api/analytics"])

    _stdout, _stderr, status = validate

    expect(status).not_to be_success
  end

  it "rejects expired usage reports" do
    write_new_reports
    (@root/"_data/analytics/install/30d.json").write(JSON.generate(
                                                       "start_date" => (Time.now.utc.to_date - 400).iso8601,
                                                       "end_date"   => (Time.now.utc.to_date - 370).iso8601,
                                                     ))

    _stdout, _stderr, status = validate

    expect(status).not_to be_success
    expect(@root/"api/analytics/install/30d.json").not_to exist
  end

  [365, 366].each do |age|
    it "#{(age == 365) ? "accepts" : "rejects"} package download reports fetched #{age} days ago" do
      write_new_reports
      path = @root/"_data/analytics/github-packages/30d.json"
      data = JSON.parse(path.read)
      data.fetch("formulae")["old"] = { "fetched_at" => (Time.now.utc - (age * 86_400)).iso8601 }
      path.write(JSON.generate(data))

      _stdout, stderr, status = validate

      expect(status.success?).to eq(age == 365), stderr
      %w[_data api].each do |prefix|
        expect((@root/prefix/"analytics/github-packages/30d.json").exist?).to eq(age == 365)
      end
    end
  end

  it "accepts an empty package report when no download counters were available" do
    write_new_reports
    (@root/"_data/analytics/github-packages/30d.json").write(JSON.generate("formulae" => {}))

    _stdout, stderr, status = validate

    expect(status).to be_success, stderr
  end

  context "when preparation or generation fails" do
    before do
      write_new_reports
      (@root/"bin").mkpath
      (@root/"bin/brew").write("#!/bin/sh\necho called >> \"$BREW_CALLS\"\nexit 1\n")
      (@root/"bin/brew").chmod(0755)
      (@root/"temporary").mkpath
    end

    def update(prepared:, key:)
      Open3.capture3(
        {
          "ANALYTICS_PREPARED"          => prepared.to_s,
          "ANALYTICS_CACHE_MATCHED_KEY" => key,
          "BREW_CALLS"                  => (@root/"brew-calls").to_s,
          "GITHUB_OUTPUT"               => (@root/"output").to_s,
          "PATH"                        => "#{@root}/bin:#{ENV.fetch("PATH")}",
          "TMPDIR"                      => (@root/"temporary").to_s,
        },
        "bash", "-euo", "pipefail", "-c", steps.find { |step| step["id"] == "update" }.fetch("run"),
        chdir: @root
      )
    end

    it "retains the snapshot and skips generation after a preparation failure" do
      _stdout, stderr, status = update(prepared: false, key: "analytics-data-v9-history-2026-10-28")

      expect(status).to be_success, stderr
      expect(@root/"brew-calls").not_to exist
      expect(@root/"output").not_to exist
      expect(validate.last).to be_success
    end

    it "rejects a preparation failure without a snapshot" do
      FileUtils.rm_rf([@root/"_data/analytics", @root/"api/analytics"])

      _stdout, _stderr, status = update(prepared: false, key: "")

      expect(status).not_to be_success
    end

    it "still rejects an unusable snapshot after a preparation failure" do
      (@root/"_data/analytics/install/30d.json").delete

      expect(update(prepared: false, key: "analytics-data-v9-history-2026-10-28").last).to be_success
      expect(validate.last).not_to be_success
    end

    it "still restores the snapshot after generation fails" do
      _stdout, stderr, status = update(prepared: true, key: "analytics-data-v9-history-2026-10-28")

      expect(status).to be_success, stderr
      expect(@root/"brew-calls").to exist
      expect(@root/"output").not_to exist
      expect(validate.last).to be_success
    end

    it "rejects a generation failure without a snapshot" do
      FileUtils.rm_rf([@root/"_data/analytics", @root/"api/analytics"])

      _stdout, _stderr, status = update(prepared: true, key: "")

      expect(status).not_to be_success
    end
  end
end
