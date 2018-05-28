require "rake"
require "rake/clean"
require "json"
require "date"

task default: :dump

desc "Dump formulae data"
task :formulae do
  sh "brew", "ruby", "script/generate.rb"
end

desc "Setup analytics"
task :setup_analytics do
  ga_credentials = ".homebrew_analytics.json"
  if File.exist?(ga_credentials)
    ga_credentials_home = File.expand_path("~/#{ga_credentials}")
    unless File.exist?(ga_credentials_home)
      FileUtils.cp ga_credentials, ga_credentials_home
    end
  end

  unless system "brew command formula-analytics &>/dev/null"
    sh "brew", "tap", "Homebrew/formula-analytics"
  end
end

desc "Dump analytics data"
task analytics: :setup_analytics do
  json_file = "_data/analytics/build-error/30d.json"
  if File.exist?(json_file)
    json = JSON.parse(IO.read(json_file))
    end_date = Date.parse(json["end_date"])
    next if end_date >= Date.today
  end

  # TODO: add API for each endpoint (at top of pages, move formulae JSON API links to top)
  %w[build-error os-version
     install install-on-request
     core-install core-install-on-request].each do |category|
    case category
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
      sh "brew formula-analytics --days-ago=#{days} --json --#{category} " \
        "> _data/analytics/#{category_name}/#{days}d.json"
    end
  end
end

desc "Dump formulae and analytics data"
task dump: %i[formulae analytics]

desc "Build the site"
task jekyll: :dump do
  sh "bundle", "exec", "jekyll", "build"
end

CLEAN.include FileList["_site"]
