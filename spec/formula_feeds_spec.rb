# frozen_string_literal: true

require "fileutils"
require "jekyll"
require "json"
require "nokogiri"
require "rspec"
require "time"
require "tmpdir"

RSpec.describe "Formula RSS rendering" do
  it "renders valid RSS with stable dates, escaped text, canonical links and removed-package fallbacks" do
    Dir.mktmpdir("formula-feed-render-") do |directory|
      project = Pathname(__dir__).parent
      site = Pathname(directory)
      entry = { "name" => "example", "date" => "2026-01-01T00:00:00Z", "commit" => "a" * 40 }
      result = {
        "new"     => [entry.merge("id" => "added:example", "versions" => ["1.0"]),
                      entry.merge("id" => "added:removed", "name" => "removed", "versions" => ["1.0"])],
        "updated" => [entry.merge("id" => "updated:example", "versions" => ["2.0"])],
      }
      (site/"_data").mkpath
      (site/"_data/formula_feeds.json").write(JSON.generate(result))
      FileUtils.cp_r(project/"feeds", site/"feeds")
      (site/"_layouts").mkpath
      FileUtils.cp(project/"_layouts/formula_feed.xml", site/"_layouts/formula_feed.xml")
      (site/"_data/formula").mkpath
      (site/"_data/formula/renamed12_.json")
        .write(JSON.generate({ "name" => "renamed@1.2+", "desc" => "Tools & <utilities>" }))
      (site/"_data/formula_canonical.json").write(JSON.generate({ "example" => "renamed@1.2+" }))
      Jekyll::Site.new(Jekyll.configuration(
                         "source" => site.to_s, "destination" => (site/"_site").to_s,
                         "url" => "https://example.test", "baseurl" => "/preview", "quiet" => true
                       )).process

      %w[new updated].each do |type|
        xml = Nokogiri::XML((site/"_site/feeds/formula-#{type}.xml").read) { |config| config.strict.nonet }
        expect(xml.xpath("/rss/channel/lastBuildDate")).to be_empty
        items = xml.xpath("/rss/channel/item")
        expect(items.length).to eq(result.fetch(type).length)
        expect(items.map { |item| item.at_xpath("guid")["isPermaLink"] }.uniq).to eq(["false"])
        expect(items.map { |item| Time.rfc2822(item.at_xpath("pubDate").text).utc.iso8601 })
          .to eq(result.fetch(type).map { |entry| entry.fetch("date") })
        example = items.find { |item| item.at_xpath("title").text.start_with?("example") }
        expect(example.at_xpath("description").text).to eq("Tools & <utilities>")
        expect(example.at_xpath("link").text).to eq("https://example.test/preview/formula/renamed@1.2+")
        expect(xml.at_xpath("/rss/channel/atom:link", "atom" => "http://www.w3.org/2005/Atom")["href"])
          .to eq("https://example.test/preview/feeds/formula-#{type}.xml")
        removed = items.find { |item| item.at_xpath("title").text.start_with?("removed") }
        if removed
          expect(removed.at_xpath("link").text).to start_with("https://github.com/Homebrew/homebrew-core/commit/")
        end
      end
    end
  end
end
