# frozen_string_literal: true

require "jekyll"
require "nokogiri"
require "rspec"
require "time"

RSpec.describe "Published package feeds" do
  %w[formula cask].each do |package|
    it "documents both #{package} feed subscriptions on the analytics page with the configured base URL" do
      config = Jekyll.configuration(
        "source" => File.expand_path("..", __dir__), "baseurl" => "/preview", "quiet" => true,
      )
      site = Jekyll::Site.new(config)
      page = Jekyll::Page.new(site, site.source, "analytics", "index.md")
      page.render({}, site.site_payload)
      document = Nokogiri::HTML(page.output)

      expect(document.at_css("#rss-feeds")).not_to be_nil
      expect(document.css("a[href^='/preview/feeds/#{package}-']").map { |link| link["href"] })
        .to contain_exactly("/preview/feeds/#{package}-new.xml", "/preview/feeds/#{package}-updated.xml")
    end

    next unless ENV["FORMULA_FEEDS_TEST_SITE"]

    it "publishes both #{package} feeds and subscription links in the built site" do
      site = Pathname(ENV.fetch("FORMULA_FEEDS_TEST_SITE")).expand_path
      { "new" => 50, "updated" => 500 }.each do |type, limit|
        xml = Nokogiri::XML((site/"feeds/#{package}-#{type}.xml").read) { |config| config.strict.nonet }
        expect(xml.xpath("/rss/channel/lastBuildDate")).to be_empty
        items = xml.xpath("/rss/channel/item")
        expect(items.length).to eq(limit)
        expect(items.map { |item| item.at_xpath("guid").text }.uniq.length).to eq(limit)
        expect(items.map { |item| item.at_xpath("link").text }).to all(
          start_with("https://formulae.brew.sh/#{package}/").or(
            start_with("https://github.com/Homebrew/homebrew-#{(package == "formula") ? "core" : "cask"}/commit/"),
          ),
        )
        items.each { |item| expect { Time.rfc2822(item.at_xpath("pubDate").text) }.not_to raise_error }
      end
      index = Nokogiri::HTML((site/"#{package}/index.html").read)
      expect(index.css("link[type='application/rss+xml'][href*='/feeds/#{package}-']").length).to eq(2)
      expect(index.css("a[href^='/feeds/#{package}-']").length).to eq(2)
      analytics = Nokogiri::HTML((site/"analytics/index.html").read)
      expect(analytics.at_css("#rss-feeds")).not_to be_nil
      expect(analytics.css("a[href^='/feeds/#{package}-']").map { |link| link["href"] })
        .to contain_exactly("/feeds/#{package}-new.xml", "/feeds/#{package}-updated.xml")
    end
  end
end
