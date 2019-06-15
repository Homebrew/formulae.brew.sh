require "rake"
require "rake/clean"
require "json"
require "date"

task default: :formula_and_analytics

desc "Dump formulae data"
task :formulae do
  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate.rb"
end

desc "Dump Linux formulae data"
task :formulae_linux do
  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  sh "brew", "ruby", "script/generate-linux.rb"
end

desc "Dump cask data"
task :cask do
  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate-cask.rb"
end

def generate_analytics?
  return false if ENV["HOMEBREW_NO_ANALYTICS"]

  json_file = "_data/analytics/build-error/30d.json"
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

desc "Dump analytics data"
task :analytics do
  next unless generate_analytics?

  setup_analytics

  %w[build-error install cask-install install-on-request os-version
     core-build-error core-install core-install-on-request].each do |category|
    case category
    when "core-build-error"
      category = "all-core-formulae-json --build-error"
      category_name = "build-error/homebrew-core"
    when "core-install"
      category = "all-core-formulae-json --install"
      category_name = "install/homebrew-core"
    when "core-install-on-request"
      category = "all-core-formulae-json --install-on-request"
      category_name = "install-on-request/homebrew-core"
    else
      category_name = category
    end
    FileUtils.mkdir_p "_data/analytics/#{category_name}"
    %w[30 90 365].each do |days|
      next if days != "30" && category_name == "build-error/homebrew-core"

      sh "brew formula-analytics --days-ago=#{days} --json --#{category} " \
        "> _data/analytics/#{category_name}/#{days}d.json"
    end
  end
end

desc "Dump Linux analytics data"
task :analytics_linux do
  next unless generate_analytics?

  setup_analytics

  %w[build-error install cask-install install-on-request os-version
     core-build-error core-install core-install-on-request].each do |category|
    case category
    when "core-build-error"
      category = "all-core-formulae-json --build-error"
      category_name = "build-error/linuxbrew-core"
    when "core-install"
      category = "all-core-formulae-json --install"
      category_name = "install/linuxbrew-core"
    when "core-install-on-request"
      category = "all-core-formulae-json --install-on-request"
      category_name = "install-on-request/linuxbrew-core"
    else
      category_name = category
    end
    FileUtils.mkdir_p "_data/analytics-linux/#{category_name}"
    %w[30 90 365].each do |days|
      next if days != "30" && category_name == "build-error/linuxbrew-core"

      sh "brew formula-analytics --linux --days-ago=#{days} --json --#{category} " \
        "> _data/analytics-linux/#{category_name}/#{days}d.json"
    end
  end
end

desc "Dump formulae and analytics data"
task formula_and_analytics: %i[formulae analytics]

desc "Dump Linux formulae and analytics data"
task linux_formula_and_analytics: %i[formulae_linux analytics_linux]

desc "Build the site"
task build: [:formula_and_analytics, :cask] do
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
