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

def setup_analytics
  ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
  return if `brew tap`.include?("homebrew/formula-analytics")

  sh "brew", "tap", "homebrew/formula-analytics"
end

desc "Dump analytics data"
task :analytics do
  setup_analytics

  sh "brew", "generate-analytics-api"
end
CLOBBER.include FileList[%w[_data/analytics api/analytics]]

desc "Update API samples"
task :api_samples do
  sh "ruby", "script/generate-api-samples.rb"
end
CLOBBER.include FileList[%w[_includes/api-samples]]
