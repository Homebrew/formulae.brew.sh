#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "net/http"
require "optparse"
require "pathname"
require "tmpdir"
require "uri"

API_ROOT = "https://formulae.brew.sh/api/"
INTERVALS = %w[30d 90d 365d].freeze
GENERATED_DIRECTORIES = %w[
  _data/analytics
  _data/cask
  _data/formula
  api/analytics
  api/cask
  api/formula
  cask
  formula
].freeze
GENERATED_FILES = %w[
  _data/cask_canonical.json
  _data/formula_canonical.json
  api/cask_tap_migrations.json
  api/formula_tap_migrations.json
].freeze

options = { root: Pathname(__dir__).parent }
OptionParser.new do |parser|
  parser.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options]"
  parser.on("--formula NAME", "Prepare one formula (repeatable)") do |name|
    (options[:formulae] ||= []) << name
  end
  parser.on("--cask TOKEN", "Prepare one cask (repeatable)") do |token|
    (options[:casks] ||= []) << token
  end
  parser.on("--root PATH", "Write into another formulae.brew.sh checkout") do |root|
    options[:root] = Pathname(root).expand_path
  end
end.parse!

abort "#{options[:root]} is not a formulae.brew.sh checkout" unless (options[:root]/"_config.yml").exist?

def fetch_json(path, redirects: 5)
  uri = URI.join(API_ROOT, path)
  puts "Downloading #{uri}"
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 15, read_timeout: 120) do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "formulae.brew.sh local preview"
    http.request(request)
  end

  if response.is_a?(Net::HTTPRedirection) && redirects.positive?
    return fetch_json(URI.join(uri, response.fetch("location")).to_s, redirects: redirects - 1)
  end

  raise "#{uri} returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
rescue JSON::ParserError => e
  raise "Could not parse JSON from #{uri}: #{e.message}"
end

def write_json(path, value)
  path.dirname.mkpath
  path.write "#{JSON.pretty_generate(value)}\n"
end

def select_packages(packages, key, requested, sample)
  return packages unless requested

  names = requested.push(sample).uniq
  selected = packages.select { |package| names.include?(package.fetch(key)) }
  missing = names - selected.map { |package| package.fetch(key) }
  abort "Unknown #{key == "name" ? "formula" : "cask"}: #{missing.join(", ")}" if missing.any?

  selected
end

def write_package_files(staging, type, packages)
  packages.each do |package|
    name = package.fetch(type == "formula" ? "name" : "token")
    write_json staging/"_data"/type/"#{name.delete("@.").tr("+", "_")}.json", package
    (staging/type/"#{name}.html").tap do |path|
      path.dirname.mkpath
      path.write <<~PAGE
        ---
        title: #{JSON.generate(name)}
        layout: #{type}
        #{type == "formula" ? "redirect_from: /formula-linux/#{name}\n" : ""}---
      PAGE
    end
    (staging/"api"/type/"#{name}.json").tap do |path|
      path.dirname.mkpath
      path.write <<~PAGE
        ---
        layout: #{type}_json
        ---
      PAGE
    end
  end
end

def write_analytics(staging, category, interval, source = nil)
  parts = ["analytics", category, source, "#{interval}.json"].compact
  write_json staging.join("_data", *parts), fetch_json(parts.join("/"))
  staging.join("api", *parts).tap do |path|
    path.dirname.mkpath
    path.write <<~PAGE
      ---
      layout: analytics_json
      category: #{category}
      #{source ? "#{source}: true\n" : ""}---
    PAGE
  end
end

formulae = fetch_json("formula.json")
casks = fetch_json("cask.json")
focused = options[:formulae] || options[:casks]
formulae = select_packages formulae, "name", focused ? options.fetch(:formulae, []) : nil, "wget"
casks = select_packages casks, "token", focused ? options.fetch(:casks, []) : nil, "docker-desktop"

Dir.mktmpdir("formulae-preview-") do |temporary_directory|
  staging = Pathname(temporary_directory)
  GENERATED_DIRECTORIES.each { |directory| (staging/directory).mkpath }

  write_package_files staging, "formula", formulae
  write_package_files staging, "cask", casks

  write_json staging/"_data/formula_canonical.json", formulae.each_with_object({}) { |formula, canonical|
    (formula.fetch("aliases", []) + formula.fetch("oldnames", [])).each { |name| canonical[name] = formula.fetch("name") }
  }
  write_json staging/"_data/cask_canonical.json", casks.each_with_object({}) { |cask, canonical|
    cask.fetch("old_tokens", []).each { |token| canonical[token] = cask.fetch("token") }
  }
  write_json staging/"api/formula_tap_migrations.json", fetch_json("formula_tap_migrations.json")
  write_json staging/"api/cask_tap_migrations.json", fetch_json("cask_tap_migrations.json")

  write_analytics staging, "install", "30d"
  %w[install install-on-request].each do |category|
    INTERVALS.each { |interval| write_analytics staging, category, interval, "homebrew-core" }
  end
  write_analytics staging, "build-error", "30d", "homebrew-core"
  INTERVALS.each { |interval| write_analytics staging, "cask-install", interval, "homebrew-cask" }

  GENERATED_DIRECTORIES.each do |directory|
    FileUtils.rm_rf options[:root]/directory
    (options[:root]/directory).dirname.mkpath
    FileUtils.mv staging/directory, options[:root]/directory
  end
  GENERATED_FILES.each do |file|
    FileUtils.rm_f options[:root]/file
    (options[:root]/file).dirname.mkpath
    FileUtils.mv staging/file, options[:root]/file
  end
end

system "ruby", "script/generate-api-samples.rb", chdir: options[:root], exception: true
puts "Prepared #{formulae.length} formulae and #{casks.length} casks."
puts "Run bundle exec jekyll serve and open http://127.0.0.1:4000/."
