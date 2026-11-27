# frozen_string_literal: true

require "json"
require "open3"
require "tmpdir"
require "yaml"

RSpec.describe "Analytics working caches" do
  it "keeps archive checkpoints separate from daily refresh checkpoints" do
    archive, refresh = %w[analytics-history analytics].map do |name|
      workflow = YAML.safe_load_file(File.expand_path("../.github/workflows/#{name}.yml", __dir__))
      workflow.fetch("jobs").values.first.fetch("steps").find do |step|
        step.fetch("uses", "").start_with?("actions/cache/restore@") &&
          step.dig("with", "key").start_with?("analytics-working-")
      end.fetch("with")
    end

    aggregate_failures do
      [[archive, refresh], [refresh, archive]].each do |own, other|
        prefixes = own.fetch("restore-keys").split
        expect(prefixes.any? { |prefix| own.fetch("key").start_with?(prefix) }).to be(true)
        expect(prefixes.any? { |prefix| other.fetch("key").start_with?(prefix) }).to be(false)
      end
      expect(archive.fetch("restore-keys").split.any? do |prefix|
        "analytics-working-v1-archive-123-1".start_with?(prefix)
      end).to be(false)
    end
  end
end

RSpec.describe "Analytics archive publishing" do
  let(:year) { 2020 }
  let(:branch) { "analytics-history-#{year}" }
  let(:archive_output) { "branch=#{branch}\ntitle=Archive analytics through #{year}\n" }
  let(:steps) do
    YAML.safe_load_file(File.expand_path("../.github/workflows/analytics-history.yml", __dir__))
        .fetch("jobs").fetch("archive").fetch("steps")
  end
  let(:archive_step) { steps.find { |step| step["id"] == "archive" } }

  around do |example|
    Dir.mktmpdir("analytics-archive-") do |directory|
      @root = Pathname(directory)
      example.run
    end
  end

  def git(*arguments)
    stdout, stderr, status = Open3.capture3("git", *arguments, chdir: @root)
    expect(status).to be_success, stderr
    stdout.strip
  end

  def publish
    Open3.capture3(
      {
        "GITHUB_OUTPUT" => (@root/"output").to_s,
        "PATH"          => "#{@root}/bin:#{ENV.fetch("PATH")}",
      },
      "bash", "-euo", "pipefail", "-c", archive_step.fetch("run"), chdir: @root
    )
  end

  before do
    git("init", "--quiet", "--initial-branch=main")
    git("config", "user.name", "Workflow Test")
    git("config", "user.email", "workflow@example.test")
    git("config", "commit.gpgsign", "false")
    (@root/"analytics").mkpath
    (@root/"analytics/history.json").write("{}\n")
    git("add", "analytics/history.json")
    git("commit", "--quiet", "-m", "Initial archive")
    git("init", "--quiet", "--bare", "--initial-branch=main", "remote.git")
    git("remote", "add", "origin", (@root/"remote.git").to_s)
    (@root/"bin").mkpath
    (@root/"bin/date").write("#!/bin/sh\necho #{year + 1}\n")
    (@root/"bin/date").chmod(0755)
    (@root/"bin/gh").write("#!/bin/sh\ntest \"$*\" = 'auth setup-git'\n")
    (@root/"bin/gh").chmod(0755)
  end

  it "proposes an archive using the published branch and title" do
    proposal = steps.find do |step|
      step.fetch("uses", "").start_with?("Homebrew/actions/get-or-create-pull-request@")
    end

    expect(steps.index(proposal)).to be > steps.index(archive_step)
    expect(proposal.fetch("if")).to eq("env.PUBLISH == 'true' && steps.archive.outputs.branch != ''")
    expect(proposal.fetch("with")).to include(
      "head"  => "${{ steps.archive.outputs.branch }}",
      "base"  => "${{ github.event.repository.default_branch }}",
      "title" => "${{ steps.archive.outputs.title }}",
    )
  end

  it "does not publish a branch when the archive is unchanged" do
    _stdout, stderr, status = publish

    expect(status).to be_success, stderr
    expect(git("ls-remote", "--heads", "origin")).to be_empty
    expect(@root/"output").not_to exist
  end

  it "publishes a new archive branch and emits its details" do
    (@root/"analytics/history.json").write(JSON.generate("year" => year))

    _stdout, stderr, status = publish

    expect(status).to be_success, stderr
    expect(git("--git-dir=remote.git", "rev-parse", "refs/heads/#{branch}")).to eq(git("rev-parse", "HEAD"))
    expect((@root/"output").read).to eq(archive_output)
  end

  [
    "matching contents",
    "different archive contents",
    "unrelated default-branch changes",
  ].each do |contents|
    it "checks an existing archive branch with #{contents}" do
      git("switch", "-c", branch)
      (@root/"analytics/history.json").write(JSON.generate(
                                               "year" => (contents == "different archive contents") ? year - 1 : year,
                                             ))
      git("add", "analytics/history.json")
      git("commit", "--quiet", "-m", "Earlier archive attempt")
      git("push", "origin", branch)
      previous = git("rev-parse", "HEAD")
      git("switch", "main")
      git("branch", "-D", branch)
      if contents == "unrelated default-branch changes"
        (@root/"unrelated").write("unrelated\n")
        git("add", "unrelated")
        git("commit", "--quiet", "-m", "Unrelated default-branch change")
      end
      (@root/"analytics/history.json").write(JSON.generate("year" => year))

      _stdout, stderr, status = publish

      expect(git("--git-dir=remote.git", "rev-parse", "refs/heads/#{branch}")).to eq(previous)
      if contents == "different archive contents"
        expect(status).not_to be_success
        expect(stderr).to include("different contents")
        expect(@root/"output").not_to exist
      else
        expect(status).to be_success, stderr
        expect((@root/"output").read).to eq(archive_output)
      end
    end
  end
end
