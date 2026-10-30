# frozen_string_literal: true

require "json"
require "open3"
require "rbconfig"
require "time"
require "tmpdir"

RSpec.describe "Analytics history archive" do
  let(:year) { Time.now.utc.year - 1 }
  let(:reports) do
    {
      "github"          => {
        "start_year"            => year,
        "generated_at"          => Time.now.utc.iso8601,
        "repositories"          => { "Homebrew/brew" => { "rows" => [{ "period" => year.to_s }] } },
        "combined_contributors" => { "rows" => [{ "period" => year.to_s, "contributors" => 1 }] },
      },
      "formula-history" => {
        "start_year"   => year,
        "generated_at" => Time.now.utc.iso8601,
        "complete"     => true,
        "rows"         => [{ "period" => year.to_s }],
      },
      "releases"        => {
        "start_year"   => year,
        "generated_at" => Time.now.utc.iso8601,
        "years"        => [{ "period" => year.to_s, "releases" => 0 }],
        "releases"     => [],
        "aggregates"   => [],
      },
    }
  end

  around do |example|
    Dir.mktmpdir("analytics-history-") do |directory|
      @root = Pathname(directory)
      example.run
    end
  end

  def update(*arguments)
    reports.each do |name, report|
      path = @root/name/"history.json"
      path.dirname.mkpath
      path.write(JSON.generate(report))
    end
    Open3.capture3(
      { "RUBYOPT" => nil },
      RbConfig.ruby, "--disable-gems", File.expand_path("../script/update-analytics-history.rb", __dir__),
      "--data=#{@root}", "--output=#{@root}/archive.json", *arguments
    )
  end

  def annual_rows(data = reports)
    {
      "repository"            => data.fetch("github").fetch("repositories").fetch("Homebrew/brew").fetch("rows"),
      "combined contributors" => data.fetch("github").fetch("combined_contributors").fetch("rows"),
      "formula history"       => data.fetch("formula-history").fetch("rows"),
      "annual releases"       => data.fetch("releases").fetch("years"),
    }
  end

  ["combined contributors", "annual releases"].each do |missing|
    [[], ["--dry-run"]].each do |arguments|
      it "rejects missing #{missing} in #{arguments.empty? ? "write" : "dry-run"} mode" do
        annual_rows.fetch(missing).clear
        (@root/"archive.json").write("{}\n")

        _stdout, stderr, status = update(*arguments)

        expect(status).not_to be_success
        expect(stderr).to include("missing #{year}")
        expect((@root/"archive.json").read).to eq("{}\n")
      end
    end
  end

  it "archives a completed year with no releases" do
    _stdout, stderr, status = update

    expect(status).to be_success, stderr
    archive = JSON.parse((@root/"archive.json").read)
    expect(archive.values.map { |report| report.fetch("through_year") }).to eq([year, year, year])
    expect(archive.fetch("releases").fetch("years")).to eq(reports.fetch("releases").fetch("years"))
  end

  context "after skipping two annual updates" do
    before do
      reports.each_value { |report| report["start_year"] = year - 3 }
      archive = JSON.parse(JSON.generate(reports))
      archive.each_value { |report| report["through_year"] = year - 3 }
      annual_rows(archive).each_value { |rows| rows.first["period"] = (year - 3).to_s }
      (@root/"archive.json").write(JSON.generate(archive))
      annual_rows.each_value do |rows|
        rows.push(rows.first.merge("period" => (year - 1).to_s), rows.first.merge("period" => (year - 2).to_s))
      end
    end

    ["repository", "combined contributors", "formula history", "annual releases"].each do |missing|
      [[], ["--dry-run"]].each do |arguments|
        it "rejects a gap in #{missing} in #{arguments.empty? ? "write" : "dry-run"} mode" do
          annual_rows.fetch(missing).reject! { |row| row.fetch("period") == (year - 1).to_s }
          original = (@root/"archive.json").read

          _stdout, stderr, status = update(*arguments)

          expect(status).not_to be_success
          expect(stderr).to include("missing #{year - 1}")
          expect((@root/"archive.json").read).to eq(original)
        end
      end
    end

    it "appends every missing year and preserves the archived rows" do
      _stdout, stderr, status = update

      expect(status).to be_success, stderr
      archive = JSON.parse((@root/"archive.json").read)
      expect(archive.values.map { |report| report.fetch("through_year") }).to eq([year, year, year])
      annual_rows(archive).each_value do |rows|
        expect(rows.map { |row| row.fetch("period") }).to eq([year, year - 1, year - 2, year - 3].map(&:to_s))
      end
    end

    context "with archived security disclosures" do
      let(:disclosure) { { "date" => "#{year - 3}-01-01", "url" => "https://brew.sh/archived-disclosure" } }

      before do
        archive = JSON.parse((@root/"archive.json").read)
        archive.fetch("github")["security_disclosures"] = [disclosure]
        (@root/"archive.json").write(JSON.generate(archive))
      end

      [false, true].each do |empty|
        it "retains disclosures when the fresh list is #{empty ? "empty" : "missing"}" do
          reports.fetch("github")["security_disclosures"] = [] if empty

          _stdout, stderr, status = update

          expect(status).to be_success, stderr
          expect(JSON.parse((@root/"archive.json").read).fetch("github").fetch("security_disclosures"))
            .to eq([disclosure])
        end
      end

      it "preserves archived entries, deduplicates URLs and excludes unfinished years" do
        fresh = { "date" => "#{year}-01-01", "url" => "https://brew.sh/new-disclosure" }
        reports.fetch("github")["security_disclosures"] = [
          disclosure.merge("date" => "#{year}-02-01"),
          fresh,
          fresh,
          { "date" => "#{year + 1}-01-01", "url" => "https://brew.sh/current-disclosure" },
        ]

        _stdout, stderr, status = update

        expect(status).to be_success, stderr
        expect(JSON.parse((@root/"archive.json").read).fetch("github").fetch("security_disclosures"))
          .to eq([disclosure, fresh])
      end
    end

    it "retains repositories omitted from the fresh report" do
      archive = JSON.parse((@root/"archive.json").read)
      archive.fetch("github").fetch("repositories")["Homebrew/legacy-homebrew"] = {
        "source" => "https://github.com/Homebrew/legacy-homebrew",
        "rows"   => [{ "period" => (year - 3).to_s, "contributors" => 1 }],
      }
      (@root/"archive.json").write(JSON.generate(archive))

      _stdout, stderr, status = update

      expect(status).to be_success, stderr
      expect(JSON.parse((@root/"archive.json").read).dig("github", "repositories", "Homebrew/legacy-homebrew"))
        .to eq(archive.dig("github", "repositories", "Homebrew/legacy-homebrew"))
    end
  end
end
