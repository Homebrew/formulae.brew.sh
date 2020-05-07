require "date"
require "json"
require "rake"
require "rake/clean"
require "yaml"

def jekyll_config(*props)
  @config ||= YAML.load_file('_config.yml')
  props.empty? ? @config : @config.dig(*props)
end

task default: :formula_and_analytics

desc "Dump macOS formulae data"
task :formulae, [:os, :tap] do |task, args|
  args.with_defaults(:os => "mac", :tap => jekyll_config("taps", "core", "name"))

  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1" if args[:os] == "mac"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate.rb", args[:os], args[:tap]
end
CLOBBER.include FileList[%w[_data/formula api/formula formula
                         _data/formula-linux api/formula-linux formula-linux]]

desc "Dump cask data"
task :cask, [:tap] do |task, args|
  args.with_defaults(:tap => jekyll_config("taps", "cask", "name"))

  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate-cask.rb", args[:tap]
end
CLOBBER.include FileList[%w[_data/cask api/cask cask]]

def generate_analytics?(os)
  return false if ENV["HOMEBREW_NO_ANALYTICS"]

  json_file = "_data/analytics#{"-linux" if os == "linux"}/build-error/30d.json"
  return true unless File.exist?(json_file)

  json = JSON.parse(IO.read(json_file))
  end_date = Date.parse(json["end_date"])
  end_date < Date.today
end

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

  sh "brew", "formula-analytics", "--setup"
end

def setup_analytics
  setup_analytics_credentials
  setup_formula_analytics_cmd
end

def generate_analytics_files(os)
  analytics_data_path = "_data/analytics"
  core_tap_name = "homebrew-core"
  formula_analytics_os_arg = nil

  if os == "linux"
    analytics_data_path = "_data/analytics-linux"
    core_tap_name = "linuxbrew-core"
    formula_analytics_os_arg = "--linux"
  end

  categories = %w[
    build-error install install-on-request
    core-build-error core-install core-install-on-request
  ]
  categories << %w[cask-install core-cask-install os-version] if os == "mac"

  categories.each do |category|
    case category
    when "core-build-error"
      category = "all-core-formulae-json --build-error"
      category_name = "build-error/#{core_tap_name}"
    when "core-install"
      category = "all-core-formulae-json --install"
      category_name = "install/#{core_tap_name}"
    when "core-install-on-request"
      category = "all-core-formulae-json --install-on-request"
      category_name = "install-on-request/#{core_tap_name}"
    when "core-cask-install"
      category = "all-core-formulae-json --cask-install"
      category_name = "cask-install/homebrew-cask"
    else
      category_name = category
    end

    FileUtils.mkdir_p "#{analytics_data_path}/#{category_name}"
    %w[30 90 365].each do |days|
      next if days != "30" && category_name == "build-error/#{core_tap_name}"

      # The `--json` and `--all-core-formulae-json` flags are mutually
      # exclusive, but we need to explicitly set `--json` sometimes,
      # so only set it if we've not already set
      # `--all-core-formulae-json`.
      category_flags = category.include?("all-core-formulae-json") ? category : "json --#{category}"

      sh "brew formula-analytics #{formula_analytics_os_arg} --days-ago=#{days} --#{category_flags} " \
        "> #{analytics_data_path}/#{category_name}/#{days}d.json"
    end
  end
end

desc "Dump analytics data"
task :analytics, [:os] do |task, args|
  args.with_defaults(:os => "mac")

  next unless generate_analytics?(args[:os])

  setup_analytics

  generate_analytics_files(args[:os])
end
CLOBBER.include FileList[%w[_data/analytics _data/analytics-linux]]

desc "Dump macOS formulae and analytics data"
task formula_and_analytics: %i[formulae analytics]

desc "Dump macOS casks and analytics data"
task cask_and_analytics: %i[cask analytics]

desc "Dump Linux formulae and analytics data"
task :linux_formula_and_analytics do
  Rake::Task["formulae"].tap(&:reenable).invoke("linux")
  Rake::Task["analytics"].tap(&:reenable).invoke("linux")
end

desc "Dump all formulae (macOS and Linux)"
task all_formulae: :formulae do
  Rake::Task["formulae"].tap(&:reenable).invoke("linux")
end

desc "Dump all analytics (macOS and Linux)"
task all_analytics: :analytics do
  Rake::Task["analytics"].tap(&:reenable).invoke("linux")
end

desc "Build the site"
task build: %i[all_formulae all_analytics cask] do
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
