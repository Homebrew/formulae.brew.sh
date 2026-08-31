#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

Dir.chdir Pathname(__dir__).parent

error = false

config = YAML.safe_load_file("_config.yml", permitted_classes: [Date, Symbol, Time], aliases: true)
intel_macos_platforms = config["intel_macos_platforms"]
valid_intel_macos_platforms = intel_macos_platforms.is_a?(Array) &&
                              !intel_macos_platforms.empty? &&
                              intel_macos_platforms.all?(String)
unless valid_intel_macos_platforms
  error = true
  warn "_config.yml: intel_macos_platforms must be a non-empty list of platform names"
  intel_macos_platforms = []
end
intel_macos_platform_labels = intel_macos_platforms.map { |platform| platform.tr("_", " ") }

%w[
  _site/api/formula.json
  _site/api/cask.json
].map { |f| Pathname(f) }.each do |path|
  next if path.exist?

  error = true
  warn "#{path}: does not exist"
end

Pathname("_site").find do |path|
  next if path.extname != ".json"

  contents = path.read.strip
  next if !contents.empty? && contents != "null" && contents != "{}"

  error = true
  warn "#{path}: bad file contents: '#{contents}'"
end

supported_platforms_table_regex = %r{
  <p>Supported\ platforms:</p>\s*
  <table\ class="full-width\ no-stack"\ id="bottles">(.*?)</table>
}mx

inspected_supported_platforms_tables = 0
supported_platform_rowgroups = Hash.new(0)

Pathname("_site/cask").glob("*.html").each do |path|
  contents = path.read
  table = contents[supported_platforms_table_regex, 1]
  unless table
    if contents.include?('scope="rowgroup"')
      error = true
      warn "#{path}: rowgroup markup exists but no supported platforms table matched"
    end
    next
  end

  inspected_supported_platforms_tables += 1
  table.scan(%r{scope="rowgroup">([^<]*)</th>}).flatten.each do |label|
    supported_platform_rowgroups[label] += 1
  end

  if table.scan("<tr>").empty?
    error = true
    warn "#{path}: supported platforms table has no rows"
  end

  table.scan(%r{<tbody>(.*?)</tbody>}m).flatten.each do |tbody|
    row_count = tbody.scan("<tr>").count
    rowspan = tbody[/<th rowspan="(\d+)" scope="rowgroup">/, 1]
    if rowspan && rowspan.to_i != row_count
      error = true
      warn "#{path}: supported platforms rowspan #{rowspan} does not match #{row_count} rows"
    end

    next unless tbody.match?(%r{<th [^>]*>Intel</th>})

    platform_labels = tbody.scan(%r{<td style="text-transform:capitalize;">\s*([^<]*?)\s*</td>}m)
                           .flatten
                           .map { |label| label.gsub("&nbsp;", " ").strip }
    if platform_labels.count != row_count
      error = true
      warn "#{path}: could not inspect every Intel platform row"
    end

    platform_labels.each do |label|
      next if intel_macos_platform_labels.include?(label)

      error = true
      warn "#{path}: #{label} is incorrectly advertised as an Intel platform"
    end
  end
end

if inspected_supported_platforms_tables.zero?
  error = true
  warn "_site/cask: no supported platforms table matched; the check is not running"
end

["Apple Silicon", "Intel", "Linux"].each do |rowgroup|
  next unless supported_platform_rowgroups[rowgroup].zero?

  error = true
  warn "_site/cask: no page renders a #{rowgroup} rowgroup"
end

rendered_package_fields = {
  "formula" => {
    "binaries"              => %r{<p>Binaries:.*?<code>.*?</code>.*?</p>}m,
    "conflict reasons"      => %r{<p>Conflicts with:.*?\(because .*?\).*?</p>}m,
    "dependency qualifiers" => %r{<p>Uses from macOS:.*?</strong> \([a-z]+, [a-z]+\).*?</p>}m,
    "keg-only reasons"      => %r{<p>Keg-only because .*?</p>}m,
    "macOS dependencies"    => %r{<p>Uses from macOS:.*?<strong>.*?</strong>.*?</p>}m,
    "services"              => %r{<p>Service:</p>.*?<code>brew services start .*?</code>}m,
  },
  "cask" => {
    "auto-updates"        => %r{<p>Current version:.*?\(auto-updates\)</p>}m,
    "artifacts"           => %r{<p>Artifacts:</p>.*?<table.*?<tr>.*?</table>}m,
    "languages"           => %r{<p>Languages:.*?<strong>.*?</strong>.*?</p>}m,
    "platform artifacts"  => %r{
      <p>Artifacts:</p>.*?
      <td>[^<]*\.AppImage.*?</td>.*?
      <td>App\ Image</td>.*?
      <td>Linux\ on\ (?:Intel|ARM64)</td>
    }mx,
    "relocated artifacts" => %r{<p>Artifacts:</p>.*?<td>([^/<]+) -&gt; /Applications/\1</td>}m,
    "Rosetta caveats"     => %r{is built for Intel macOS and requires Rosetta 2 on Apple Silicon},
  },
}

rendered_package_fields.each do |type, fields|
  found_fields = fields.transform_values { false }
  Pathname("_site/#{type}").glob("*.html").each do |path|
    contents = path.read
    fields.each do |field, regex|
      found_fields[field] ||= contents.match?(regex)
    end
    break if found_fields.values.all?
  end

  found_fields.each do |field, found|
    next if found

    error = true
    warn "_site/#{type}: no page renders #{field}"
  end
end

abort if error
