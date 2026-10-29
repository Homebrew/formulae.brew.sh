# frozen_string_literal: true

require "jekyll"
require "nokogiri"
require_relative "../_plugins/analytics"

RSpec.describe AnalyticsFilters do
  subject(:filters) { Object.new.extend(described_class) }

  describe "#analytics_report" do
    let(:row) { { "pull_requests_opened" => 3, "pull_requests_merged" => 2 } }
    let(:data) do
      {
        "repositories"          => { "Homebrew/brew" => { "rows" => [row] } },
        "combined_contributors" => { "rows" => [] },
      }
    end

    subject(:reported_row) do
      filters.analytics_report(data, "github").fetch("repositories").fetch("Homebrew/brew")
             .fetch("rows").first
    end

    it "reports merged PRs as a percentage of opened PRs to one decimal place" do
      expect(reported_row.fetch("merge_rate")).to eq(66.7)
    end

    it "leaves the rate unavailable when no PRs were opened" do
      row["pull_requests_opened"] = 0
      expect(reported_row).to include("pull_requests_merged" => 0, "merge_rate" => nil)
    end

    it "leaves the rate unavailable when merge counts are missing" do
      row.delete("pull_requests_merged")
      expect(reported_row.fetch("merge_rate")).to be_nil
    end

    it "caps merged PRs at opened PRs and the merge rate at 100 percent" do
      row["pull_requests_opened"] = 65
      row["pull_requests_merged"] = 67
      expect(reported_row).to include("pull_requests_merged" => 65, "merge_rate" => 100.0)
    end
  end
end

RSpec.describe "Formula history analytics page" do
  it "displays other version changes from the archive" do
    site = Jekyll::Site.new(Jekyll.configuration("source" => File.expand_path("..", __dir__), "quiet" => true))
    site.data["analytics"] = {
      "formula-history" => {
        "history" => JSON.parse(File.read(File.expand_path("../analytics/history.json", __dir__)))
                         .fetch("formula-history"),
      },
    }
    page = Jekyll::Page.new(site, site.source, "analytics", "formula-history.html")
    page.render({}, site.site_payload)
    table = Nokogiri::HTML(page.output).at_css("table")
    column = table.css("thead th").map(&:text).map(&:strip).index("Other")

    expect(column).not_to be_nil
    expect(table.css("tbody tr").find { |row| row.at_css("th").text.strip == "2025" }
                .css("th, td")[column].text.strip).to eq("317")
  end
end

RSpec.describe "Analytics pages without generated reports" do
  it "marks missing reports as unavailable" do
    site = Jekyll::Site.new(Jekyll.configuration("source" => File.expand_path("..", __dir__), "quiet" => true))
    %w[github github-packages releases formula-history].each do |report|
      page = Jekyll::Page.new(site, site.source, "analytics", "#{report}.html")
      page.render({}, site.site_payload)

      expect(page.output).to include("not yet available")
    end
  end
end
