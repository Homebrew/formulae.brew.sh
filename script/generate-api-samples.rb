#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"

ROOT = Pathname(__dir__).parent.freeze

SAMPLES = {
  analytics_cask_install_homebrew_cask_30d: "analytics/cask-install/homebrew-cask/30d.json",
  analytics_install_30d:                    "analytics/install/30d.json",
  analytics_install_homebrew_core_30d:      "analytics/install/homebrew-core/30d.json",
  cask_docker:                              "cask/docker.json",
  formula_wget:                             "formula/wget.json",
  formula:                                  "formula/wget.json",
}.freeze

# Use template values for the API contents to allow testing without generating all API files
USE_TEMPLATES = ARGV.include? "--template"
TEMPLATE = <<~TEMPLATE
  {
    "name": "@@TEMPLATE@@",
    "formulae": [],
    "items": []
  }
TEMPLATE

def failed!
  @failed ||= true
end

def failed?
  @failed
end

def generate_api_samples
  includes_dir = "_includes/api-samples"

  FileUtils.rm_rf includes_dir
  FileUtils.mkdir_p includes_dir

  SAMPLES.each do |name, api_path|
    contents = if File.extname(api_path) == ".json"
      format_json_contents name, api_path
    else
      codify api_file_contents(api_path), language: "rb"
    end

    File.write "#{includes_dir}/#{name}.md", contents
  end
end

def api_file_contents(api_path)
  return TEMPLATE if USE_TEMPLATES

  api_file = ROOT/"_data/#{api_path}"
  return api_file.read.strip if api_file.exist?

  warn "Skipping missing API file: #{api_file}"
  failed!
end

def codify(contents, language:)
  "```#{language}\n#{contents}\n```"
end

def format_json_contents(name, api_path)
  contents = api_file_contents(api_path)
  return if failed?

  contents = JSON.parse contents

  # Only include a select group of items to reduce the length of the sample
  case name
  when :analytics_cask_install_homebrew_cask_30d
    contents["formulae"].select! do |token, _|
      %w[docker docker-edge docker-toolbox].include? token
    end
  when :analytics_install_30d
    contents["items"].select! do |obj|
      ["wget", "wget --HEAD"].include? obj["formula"]
    end
  when :analytics_install_homebrew_core_30d
    contents["formulae"].select! do |formula_name, _|
      formula_name == "wget"
    end
  end

  contents = JSON.pretty_generate contents

  # Consolidate empty [] and {} into one-liners
  contents.gsub!(/: \[\n+\s*\]/, ": []")
  contents.gsub!(/: {\n+\s*}/, ": {}")

  # Add "..." where needed
  case name
  when :analytics_cask_install_homebrew_cask_30d
    contents.sub!(/("formulae": {)/, "\\1\n    ...")
    contents.sub!(/\](?=\n  }\n})/, "],\n    ...")
  when :analytics_install_30d
    contents.sub!(/("items": \[)/, "\\1\n    ...")
    contents.sub!(/(    },)(?=\n    {)/, "\\1\n    ...")
    contents.sub!(/}(?=\n  \]\n})/, "},\n    ...")
  when :analytics_install_homebrew_core_30d
    contents.sub!(/("formulae": {)/, "\\1\n    ...")
    contents.sub!(/}(?=\n    \])/, "},\n      ...")
    contents.sub!(/\](?=\n  }\n})/, "],\n    ...")
  when :formula
    # Each entry in the formula list is a full formula without the analytics or generated date
    contents.sub!(/(},\n  "analytics":*)$/, "}\n}")
    contents = contents.lines.map { |line| "  #{line}" }.join
    contents = <<~RESPONSE.strip
      [
        ...
      #{contents},
        ...
      ]
    RESPONSE
  end

  codify contents, language: "json"
end

generate_api_samples

abort if failed?
