# frozen_string_literal: true

require "yaml"

RSpec.describe "CI workflow checkouts" do
  it "keeps every job's scripts in sync with the workflow on out-of-date pull requests" do
    workflow = YAML.safe_load_file(File.expand_path("../.github/workflows/tests.yml", __dir__))

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
