require "date"
require "json"
require "rake"
require "rake/clean"
require "yaml"

task default: :generate

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
  unless `brew tap`.include?("homebrew/formula-analytics")
    sh "brew", "tap", "Homebrew/formula-analytics"
  end
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
CLOBBER.include FileList[%w[_data/analytics _data/analytics-linux api/analytics api/analytics-linux]]

desc "Update API samples"
task :api_samples do
  sh "ruby", "script/generate-api-samples.rb"
end
CLOBBER.include FileList[%w[_includes/api-sample]]

desc "Generate the API files"
task generate: %i[formulae casks analytics api_samples]

desc "Build the site"
task :build do
  require 'jekyll'
  Jekyll::Commands::Build.process({})
end
CLEAN.include FileList["_site"]

desc "Serve the site"
task :serve do
  require 'jekyll'
  Jekyll::Commands::Serve.process({})
end

desc "Run html proofer to validate the HTML output."
task html_proofer: :build do
  require "html-proofer"
  HTMLProofer.check_directory(
    "./_site",
    parallel: { in_threads: 4 },
    favicon: true,
    http_status_ignore: [0, 302, 303, 429, 521],
    assume_extension: true,
    check_external_hash: true,
    check_favicon: true,
    check_opengraph: true,
    check_img_http: true,
    disable_external: true,
    url_ignore: ["http://formulae.brew.sh"]
  ).run
end

desc "Run JSON Lint to validate the JSON output."
task jsonlint: :build do
  require "jsonlint"
  files_to_check = FileList["_site/**/*.json"]
  puts "Running JSON Lint on #{files_to_check.flatten.length} files..."

  linter = JsonLint::Linter.new
  linter.check_all(files_to_check)

  if linter.errors?
    linter.display_errors
    abort "JSON Lint found #{linter.errors_count} errors!"
  else
    puts "JSON Lint finished successfully."
  end
end

task test: %i[html_proofer jsonlint]
