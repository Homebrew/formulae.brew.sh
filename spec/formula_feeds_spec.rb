# frozen_string_literal: true

require "bundler"
require "fileutils"
require "jekyll"
require "json"
require "nokogiri"
require "open3"
require "rspec"
require "time"
require "tmpdir"

RSpec.describe "Formula RSS feeds" do
  let(:project) { Pathname(__dir__).parent }
  let(:repository) { @root/"core" }
  let(:output) { @root/"site/_data/formula_feeds.json" }

  around do |example|
    Dir.mktmpdir("formula-feeds-") do |directory|
      @root = Pathname(directory)
      @time = Time.utc(2026, 1, 1)
      repository.mkpath
      git("init", "--quiet", "--initial-branch=main")
      git("config", "user.name", "Feed tests")
      git("config", "user.email", "feeds@example.test")
      git("config", "commit.gpgsign", "false")
      example.run
    end
  end

  def git(*args, path: repository)
    stdout, stderr, status = Open3.capture3("git", "-C", path.to_s, *args)
    raise stderr unless status.success?

    stdout.strip
  end

  def commit(message = "Change formula")
    git("add", ".")
    @time += 60
    _stdout, stderr, status = Open3.capture3(
      { "GIT_AUTHOR_DATE" => @time.iso8601, "GIT_COMMITTER_DATE" => @time.iso8601 },
      "git", "-C", repository.to_s, "commit", "--quiet", "-m", message
    )
    raise stderr unless status.success?

    git("rev-parse", "HEAD")
  end

  def formula(name = "example", version: "1.0", revision: 0, rebuild: 0, extra: "")
    path = repository/"Formula"/"#{name}.rb"
    path.dirname.mkpath
    path.write <<~RUBY
      class #{name.split("-").map(&:capitalize).join} < Formula
        desc "Tools & utilities"
        homepage "https://example.test"
        url "https://example.test/#{name}-#{version}.tar.gz"
        version "#{version}"
        sha256 "#{"a" * 64}"
        license "MIT"
        revision #{revision}
        bottle do
          rebuild #{rebuild}
        end
        #{extra}
      end
    RUBY
    path
  end

  def generate(path: repository)
    Bundler.with_unbundled_env do
      Open3.capture3(
        { "HOMEBREW_NO_AUTO_UPDATE" => "1", "PATH" => "#{project}/script:#{ENV.fetch("PATH")}" },
        "brew", "generate-formula-feeds",
        "--repository", path.to_s, "--output", output.to_s
      )
    end
  end

  def feeds
    _stdout, stderr, status = generate
    expect(status).to be_success, stderr
    JSON.parse(output.read)
  end

  it "uses merged changes once and excludes bottles, resources, aliases and renames" do
    path = formula
    added = commit
    git("switch", "--quiet", "-c", "release")
    formula(version: "1.1")
    commit
    formula(version: "1.2")
    commit
    git("switch", "--quiet", "main")
    git("merge", "--quiet", "--no-ff", "release", "-m", "Merge release")
    released = git("rev-parse", "HEAD")
    formula(version: "1.2", revision: 1)
    revised = commit
    formula(version: "1.2", revision: 1, rebuild: 1)
    commit
    formula(version: "1.2", revision: 1, rebuild: 1, extra: <<~RUBY)
      resource "helper" do
        url "https://example.test/helper-2.0.tar.gz"
        sha256 "#{"b" * 64}"
      end
    RUBY
    commit
    renamed_path = repository/"Formula/e/example.rb"
    renamed_path.dirname.mkpath
    FileUtils.mv(path, renamed_path)
    (repository/"Aliases").mkpath
    File.symlink("../Formula/e/example.rb", repository/"Aliases/alias")
    commit

    result = feeds
    expect(result.fetch("new").map { |entry| entry.fetch("commit") }).to eq([added])
    expect(result.fetch("updated").map { |entry| entry.fetch("commit") }).to eq([revised, released])
    expect(result.fetch("updated").map { |entry| entry.fetch("versions") }).to eq([["1.2_1"], ["1.2"]])
    expect(result.fetch("updated").first.fetch("date")).to eq((Time.utc(2026, 1, 1) + (4 * 60)).iso8601)
    expect(feeds).to eq(result)
  end

  it "counts a platform-specific version change once" do
    formula(extra: "on_linux do\n    version \"2.0\"\n  end")
    commit
    formula(extra: "on_linux do\n    version \"2.1\"\n  end")
    commit
    result = feeds
    expect(result.fetch("updated").length).to eq(1)
    expect(result.fetch("updated").first.fetch("versions")).to eq(["1.0", "2.1"])
  end

  ["1.0", "2.0"].each do |version|
    it "recognizes a heavily edited move with version #{version}" do
      path = formula(extra: (1..40).map { |index| "# Original source line #{index}" }.join("\n"))
      added = commit
      formula(version:, extra: (1..40).map { |index| "# Replacement source line #{index}" }.join("\n"))
      moved_path = repository/"Formula/e/example.rb"
      moved_path.dirname.mkpath
      FileUtils.mv(path, moved_path)
      moved = commit
      expect(git("diff", "HEAD^", "HEAD", "--name-status", "--find-renames=50%").lines.map(&:strip))
        .to contain_exactly("A\tFormula/e/example.rb", "D\tFormula/example.rb")

      result = feeds
      expect(result.fetch("new").map { |entry| entry.fetch("commit") }).to eq([added])
      updates = result.fetch("updated")
      if version == "1.0"
        expect(updates).to be_empty
      else
        expect(updates.map { |entry| entry.fetch("commit") }).to eq([moved])
        expect(updates.first.fetch("versions")).to eq([version])
      end
    end
  end

  it "treats a formula reintroduced after a separate deletion as an addition" do
    path = formula
    added = commit
    path.unlink
    commit
    formula(version: "2.0")
    reintroduced = commit

    result = feeds
    expect(result.fetch("new").map { |entry| entry.fetch("commit") }).to eq([reintroduced, added])
    expect(result.fetch("updated")).to be_empty
  end

  it "validates each formula path even when source blobs are identical" do
    path = formula
    FileUtils.cp(path, repository/"Formula/zother.rb")
    commit
    output.dirname.mkpath
    output.write("previous data")

    _stdout, stderr, status = generate
    expect(status).not_to be_success
    expect(stderr).to include("Cannot read formula metadata for Formula/zother.rb")
    expect(output.read).to eq("previous data")
  end

  it "replaces the output without modifying the file held by existing readers" do
    formula
    commit
    output.dirname.mkpath
    output.write("previous data")

    output.open do |previous|
      result = feeds
      expect(result.fetch("new").first.fetch("name")).to eq("example")
      expect(previous.read).to eq("previous data")
    end
    expect(output.dirname.children).to eq([output])
  end

  it "continues through history pages containing no formula changes" do
    formula
    commit
    100.times do |index|
      (repository/"README").write(index.to_s)
      commit
    end
    formula(version: "2.0")
    commit
    result = feeds
    expect(result.fetch("new").map { |entry| entry.fetch("versions") }).to eq([["1.0"]])
    expect(result.fetch("updated").map { |entry| entry.fetch("versions") }).to eq([["2.0"]])
  end

  it "caps the feeds at 50 additions and 500 updates even within a single commit" do
    501.times { |index| formula("package-#{index}") }
    commit
    501.times { |index| formula("package-#{index}", version: "2.0") }
    commit
    result = feeds
    expect(result.fetch("new").length).to eq(50)
    expect(result.fetch("updated").length).to eq(500)
    expect(result.fetch("updated").map { |entry| entry.fetch("id") }.uniq.length).to eq(500)

    formula("fresh")
    formula("package-0", version: "3.0")
    commit
    refreshed = feeds
    expect(refreshed.fetch("new").first.fetch("name")).to eq("fresh")
    expect(refreshed.fetch("updated").first.fetch("versions")).to eq(["3.0"])
    { "new" => 50, "updated" => 500 }.each do |type, limit|
      expect(refreshed.fetch(type).length).to eq(limit)
      previous_ids = result.fetch(type).map { |entry| entry.fetch("id") }
      refreshed_ids = refreshed.fetch(type).map { |entry| entry.fetch("id") }
      expect((previous_ids & refreshed_ids).length).to eq(limit - 1)
    end
  end

  it "fails without replacing the output when formula metadata cannot be read" do
    path = formula
    commit
    output.dirname.mkpath
    output.write("previous data")
    path.write("class Example < Formula\n  invalid_metadata!\nend\n")
    commit
    _stdout, stderr, status = generate
    expect(status).not_to be_success
    expect(stderr).to include("Cannot read formula metadata")
    expect(output.read).to eq("previous data")
  end

  it "rejects a shallow checkout instead of treating its boundary as additions" do
    formula
    commit
    formula(version: "2.0")
    commit
    shallow = @root/"shallow"
    git("clone", "--quiet", "--depth=1", "file://#{repository}", shallow.to_s)
    _stdout, stderr, status = generate(path: shallow)
    expect(status).not_to be_success
    expect(stderr).to include("unshallow")
    expect(output).not_to exist
  end

  it "renders valid RSS with stable dates, escaped text, canonical links and removed-package fallbacks" do
    formula
    commit
    formula(version: "2.0")
    commit
    formula("removed")
    commit
    (repository/"Formula/removed.rb").unlink
    commit
    result = feeds
    site = output.parent.parent
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
