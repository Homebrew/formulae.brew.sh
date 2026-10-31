# frozen_string_literal: true

require "json"
require "open3"
require "tmpdir"
require "yaml"

RSpec.describe "Analytics archive publishing" do
  let(:year) { 2020 }
  let(:branch) { "analytics-history-#{year}" }
  let(:publishing) do
    YAML.safe_load_file(File.expand_path("../.github/workflows/analytics-history.yml", __dir__))
        .fetch("jobs").fetch("archive").fetch("steps").find { |step| step["id"] == "archive" }.fetch("run")
  end

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

  def publish(environment = {})
    Open3.capture3(
      {
        "GITHUB_OUTPUT" => (@root/"output").to_s,
        "PATH"          => "#{@root}/bin:#{ENV.fetch("PATH")}",
      }.merge(environment),
      "bash", "-euo", "pipefail", "-c", publishing, chdir: @root
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
    (@root/"bin/gh").write(<<~SH)
      #!/bin/sh
      if [ "$1 $2" = "pr list" ]; then
        while [ "$#" -gt 0 ]; do
          if [ "$1" = "--jq" ]; then
            echo "$OPEN_PRS" | jq -r "$2"
            exit
          fi
          shift
        done
      fi
    SH
    (@root/"bin/gh").chmod(0755)
  end

  [
    "matching contents",
    "different archive contents",
    "unrelated default-branch changes",
  ].product(["absent", "local", "fork"]).each do |contents, pull_request|
    it "checks #{contents} with #{pull_request} pull requests" do
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

      _stdout, stderr, status = publish(
        "OPEN_PRS" => JSON.generate(
          if pull_request == "absent"
            []
          else
            [{ "number" => 123, "isCrossRepository" => pull_request == "fork" }]
          end,
        ),
      )

      expect(git("--git-dir=remote.git", "rev-parse", "refs/heads/#{branch}")).to eq(previous)
      if contents == "different archive contents"
        expect(status).not_to be_success
        expect(stderr).to include("different contents")
      else
        expect(status).to be_success, stderr
      end
      if contents != "different archive contents" && pull_request != "local"
        expect((@root/"output").read).to include("branch=#{branch}\n")
      else
        expect(@root/"output").not_to exist
      end
    end
  end

  ["", "123"].each do |output|
    it "fails when PR lookup returns #{output.inspect} and exits with an error" do
      (@root/"analytics/history.json").write(JSON.generate("year" => year))
      (@root/"bin/gh").write(<<~SH)
        #!/bin/sh
        if [ "$1 $2" = "pr list" ]; then
          printf '%s' '#{output}'
          exit 42
        fi
      SH

      _stdout, stderr, status = publish

      expect(status.exitstatus).to eq(42), stderr
      expect(@root/"output").not_to exist
    end
  end
end
