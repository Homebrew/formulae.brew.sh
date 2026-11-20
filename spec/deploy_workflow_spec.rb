# frozen_string_literal: true

require "yaml"

RSpec.describe "CI workflow deployment" do
  let(:steps) do
    YAML.safe_load_file(File.expand_path("../.github/workflows/tests.yml", __dir__)).dig("jobs", "deploy", "steps")
  end
  let(:deploys) { steps.select { |step| step.fetch("uses", "").start_with?("actions/deploy-pages@") } }

  it "retries the Pages deployment with the same action and inputs" do
    expect(deploys.length).to eq(2)
    expect(deploys.map { |step| step.slice("uses", "with") }.uniq.length).to eq(1)
  end

  # Otherwise a failed deployment would leave the job, and the deploy failure issue, green.
  it "fails the job if the retry fails" do
    expect(deploys.map { |step| step["continue-on-error"] }).to eq([true, nil])
  end
end
