# frozen_string_literal: true

require "date"
require "json"
require "rake"
require "rake/clean"
require "yaml"

task default: :generate

desc "Generate API files"
task generate: [:formulae, :casks, :analytics, :api_samples]

desc "Dump formula data"
task :formulae do
  sh "brew", "generate-formula-api"
end
CLOBBER.include FileList[%w[_data/formula _data/formula_canonical.json api/formula api/formula_tap_migrations.json api/internal formula]]

desc "Dump cask data"
task :casks do
  sh "brew", "generate-cask-api"
end
CLOBBER.include FileList[%w[_data/cask _data/cask_canonical.json api/cask api/cask-source api/cask_tap_migrations.json cask]]

desc "Dump analytics data"
task :analytics do
  sh "brew", "generate-analytics-api"
end
CLOBBER.include FileList[%w[_data/analytics api/analytics]]

desc "Update API samples"
task :api_samples, [:options] do |_, args|
  generate_args = %w[ruby script/generate-api-samples.rb]
  generate_args << "--template" if args.options == "template"
  sh(*generate_args)
end
CLOBBER.include FileList[%w[_includes/api-samples]]
