# frozen_string_literal: true

require "yaml"

RSpec.describe "CI workflow" do
  let(:workflow) { YAML.safe_load_file(File.expand_path("../.github/workflows/tests.yml", __dir__)) }

  it "checks production packages on a schedule independent of the deployment queue" do
    monitor = YAML.safe_load_file(File.expand_path("../.github/workflows/published-packages.yml", __dir__))
    expect(monitor.fetch("on")).to eq("schedule" => [{ "cron" => "7 * * * *" }])
    expect(workflow.dig("jobs", "deploy", "timeout-minutes")).to eq(20)
    expect(workflow.dig("jobs", "deploy", "steps").none? { |step| step["id"] == "packages" }).to be(true)
    expect(monitor.dig("jobs", "check", "concurrency", "group")).not_to eq(workflow.dig("concurrency", "group"))
  end

  it "keeps every job's scripts in sync with the workflow on out-of-date pull requests" do
    aggregate_failures do
      workflow.fetch("jobs").each do |name, job|
        job.fetch("steps").each do |step|
          next unless step.fetch("uses", "").start_with?("actions/checkout@")
          next if step.dig("with", "repository")

          # The default checkout includes base-branch additions in the PR merge commit.
          expect(step.fetch("with", {}).fetch("ref", "${{ github.sha }}"))
            .to eq("${{ github.sha }}"), "#{name} must check out the workflow revision, including base-branch scripts"
        end
      end
    end
  end
end
