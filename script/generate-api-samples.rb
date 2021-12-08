#!/usr/bin/env brew ruby

SAMPLES = {
  analytics_cask_install_homebrew_cask_30d: "analytics/cask-install/homebrew-cask/30d.json",
  analytics_install_30d:                    "analytics/install/30d.json",
  analytics_install_homebrew_core_30d:      "analytics/install/homebrew-core/30d.json",
  bottle_wget:                              "bottle/wget.json",
  cask_docker:                              "cask/docker.json",
  cask_source_vagrant:                      "cask-source/vagrant.rb",
  formula_wget:                             "formula/wget.json",
  formula:                                  "formula.json",
  versions_casks:                           "versions-casks.json",
  versions_formulae:                        "versions-formulae.json",
}.freeze

def generate_api_samples
  includes_dir = "_includes/api-samples"

  FileUtils.rm_rf includes_dir
  FileUtils.mkdir_p includes_dir

  SAMPLES.each do |name, api_url|
    contents = if File.extname(api_url) == ".json"
      format_json_contents name, api_url
    else
      codify curl_output(api_url), language: "rb"
    end

    IO.write "#{includes_dir}/#{name}.md", contents
  end
end

def curl_output(api_url)
  out, err, status = Open3.capture3("curl", "--silent", "--show-error", "--fail", "https://formulae.brew.sh/api/#{api_url}")
  raise "Error fetching #{api_url}: #{err}" unless status.success?

  out.strip
end

def codify(contents, language:)
  "```#{language}\n#{contents}\n```"
end

def format_json_contents(name, api_url)
  contents = JSON.parse curl_output(api_url)

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
  when :versions_casks
    contents.select! do |cask_token, _|
      %w[docker onyx].include? cask_token
    end
  when :versions_formulae
    contents.select! do |formula_name, _|
      %w[wget zsh].include? formula_name
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
  when :versions_casks, :versions_formulae
    contents.sub!(/^{/, "{\n  ...")
    contents.sub!(/(  },)(?=\n  ")/, "\\1\n  ...")
    contents.sub!(/}(?=\n})/, "},\n  ...")
  end

  codify contents, language: "json"
end

generate_api_samples
