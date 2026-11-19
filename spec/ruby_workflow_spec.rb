# frozen_string_literal: true

require "yaml"

RSpec.describe "CI workflow Ruby" do
  let(:workflows) do
    Dir[File.expand_path("../.github/workflows/*.yml", __dir__)].to_h do |path|
      [File.basename(path), YAML.safe_load_file(path)]
    end
  end

  def steps(workflow)
    workflow.fetch("jobs").values.flat_map { |job| job.fetch("steps", []) }
  end

  # `.ruby-version` is synced from brew's Portable Ruby version, which other Ruby installers may not offer yet.
  it "sets up Ruby only with Homebrew's Portable Ruby" do
    aggregate_failures do
      workflows.each do |name, workflow|
        steps(workflow).each do |step|
          uses = step.fetch("uses", "")
          expect(uses).not_to start_with("ruby/setup-ruby@"), name
          next unless uses.start_with?("Homebrew/actions/setup-ruby@")

          expect(step.dig("with", "portable-ruby")).to be(true), name
        end
      end
    end
  end

  it "does not export a GitHub token into the signing job" do
    setup = workflows.fetch("tests.yml").dig("jobs", "deploy", "steps")
                     .find { |step| step.fetch("uses", "").start_with?("Homebrew/actions/setup-homebrew@") }
    expect(setup).not_to be_nil
    expect(setup.dig("with", "brew-gh-api-token")).to eq("")
  end
end
