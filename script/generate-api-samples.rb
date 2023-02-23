#!/usr/bin/env ruby

require "fileutils"
require "json"
require "open3"

SAMPLES = {
  analytics_cask_install_homebrew_cask_30d: "analytics/cask-install/homebrew-cask/30d.json",
  analytics_install_30d:                    "analytics/install/30d.json",
  analytics_install_homebrew_core_30d:      "analytics/install/homebrew-core/30d.json",
  cask_docker:                              "cask/docker.json",
  formula_wget:                             "formula/wget.json",
  formula:                                  "formula.json",
}.freeze

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
      codify curl_output(api_path), language: "rb"
    end

    IO.write "#{includes_dir}/#{name}.md", contents
  end
end

def curl_output(api_path)
  api_url = "https://formulae.brew.sh/api/#{api_path}"
  out, err, status = Open3.capture3("curl", "--silent", "--show-error", "--fail", api_url)
  unless status.success?
    warn "Error fetching #{api_url}: #{err}"
    # Return something JSON.parse can handle and we'll warn later.
    failed!
    return "{}"
  end

  out.strip
end

def codify(contents, language:)
  "```#{language}\n#{contents}\n```"
end

def format_json_contents(name, api_path)
  contents = JSON.parse curl_output(api_path)

  # TODO: remove when passing
  if contents.nil?
    warn "Skipping nil #{api_path}"
    failed!
    return
  end

  if contents.empty?
    warn "Skipping empty #{api_path}"
    failed!
    return
  end

  if contents == 'null'
    warn "Skipping null #{api_path}"
    failed!
    return
  end

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
  when :formula
    contents.select! do |obj|
      obj["name"] == "wget"
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
    contents.sub!(/^\[/, "[\n  ...")
    contents.sub!(/}(?=\n\])/, "},\n  ...")
  end

  codify contents, language: "json"
end

generate_api_samples

abort if failed?
