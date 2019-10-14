require "rake"
require "rake/clean"
require "json"
require "date"

task default: :formula_and_analytics

desc "Dump macOS formulae data"
task :formulae do
  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate.rb"
end

desc "Dump Linux formulae data"
task :formulae_linux do
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate-linux.rb"
end

desc "Dump cask data"
task :cask do
  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate-cask.rb"
end

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

  %w[build-error install cask-install install-on-request os-version
     core-build-error core-install core-install-on-request].each do |category|
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
    else
      category_name = category
    end

    FileUtils.mkdir_p "#{analytics_data_path}/#{category_name}"
    %w[30 90 365].each do |days|
      next if days != "30" && category_name == "build-error/#{core_tap_name}"

      sh "brew formula-analytics #{formula_analytics_os_arg} --days-ago=#{days} --json --#{category} " \
        "> #{analytics_data_path}/#{category_name}/#{days}d.json"
    end
  end
end

desc "Dump analytics data"
task :analytics, [:os] do |task, args|
  args.with_defaults(:os => "mac")

  next unless generate_analytics?(args.os)

  setup_analytics

  generate_analytics_files(args.os)
end

desc "Dump macOS formulae and analytics data"
task formula_and_analytics: %i[formulae analytics]

desc "Dump Linux formulae and analytics data"
task :linux_formula_and_analytics do
  Rake::Task["formulae_linux"].invoke
  Rake::Task["analytics"].invoke("linux")
end

desc "Build the site"
task build: [:formula_and_analytics, :cask, :linux_formula_and_analytics] do
  sh "bundle", "exec", "jekyll", "build"
end

desc "Run html proofer to validate the HTML output."
task html_proofer: :build do
  require "html-proofer"
  HTMLProofer.check_directory(
    "./_site",
    parallel: { in_threads: 4 },
    favicon: true,
    http_status_ignore: [0],
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
  files_to_check = Rake::FileList.new(["./_site/**/*.json"])
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

CLEAN.include FileList["_site"]
