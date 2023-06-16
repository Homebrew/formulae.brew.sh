# frozen_string_literal: true

require "date"
require "json"
require "rake"
require "rake/clean"
require "yaml"

task default: :generate

desc "Generate the API files"
task generate: [:formulae, :casks, :analytics, :api_samples]

desc "Dump macOS formulae data"
task :formulae do
  sh "brew", "generate-formula-api"
end
CLOBBER.include FileList[%w[_data/formula api/formula formula _data/formula_canonical.json]]

desc "Dump cask data"
task :casks do
  sh "brew", "generate-cask-api"
end
CLOBBER.include FileList[%w[_data/cask api/cask api/cask-source cask]]

def setup_analytics_credentials
  ga_credentials = ".homebrew_analytics.json"
  return unless File.exist?(ga_credentials)

  ga_credentials_home = File.expand_path("~/#{ga_credentials}")
  return if File.exist?(ga_credentials_home)

  FileUtils.cp ga_credentials, ga_credentials_home
end

def setup_formula_analytics_cmd
  ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
  return if `brew tap`.include?("homebrew/formula-analytics")

  sh "brew", "tap", "Homebrew/formula-analytics"
end

def setup_analytics
  setup_analytics_credentials
  setup_formula_analytics_cmd
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
CLOBBER.include FileList[%w[_includes/api-sample]]
