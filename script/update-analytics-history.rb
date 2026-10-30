#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname" # rubocop:disable Lint/RedundantRequireStatement -- Archive CI may use Ruby < 4.
require "time"

options = { data: "_data/analytics", output: "analytics/history.json", dry_run: false }
OptionParser.new do |parser|
  parser.on("--dry-run", "Validate and report changes without writing") { options[:dry_run] = true }
  parser.on("--data=PATH") { |value| options[:data] = value }
  parser.on("--output=PATH") { |value| options[:output] = value }
end.parse!

year = Time.now.utc.year - 1
output = Pathname(options.fetch(:output))
archive = output.exist? ? JSON.parse(output.read) : {}
unless archive.empty?
  %w[github formula-history releases].each do |name|
    report = archive.fetch(name)
    cutoff = report.fetch("through_year")
    abort "#{name}: cannot freeze the current or a future year" unless (2009..year).cover?(cutoff)
    rows = case name
    when "github"
      report.fetch("repositories").values.flat_map { |repository| repository.fetch("rows") } +
      report.fetch("combined_contributors").fetch("rows")
    when "formula-history" then report.fetch("rows")
    when "releases" then report.fetch("releases") + report.fetch("aggregates") + report.fetch("years", [])
    end
    unless rows.all? { |row| (2009..cutoff).cover?((row["period"] || row.fetch("date")[0, 4]).to_i) }
      abort "#{name}: rows must contain only completed years through #{cutoff}"
    end
  end
end

reports = %w[github formula-history releases].to_h do |name|
  path = Pathname(options.fetch(:data))/name/"history.json"
  [name, path.exist? ? JSON.parse(path.read) : nil]
end
if reports.values.any?(&:nil?)
  if !options[:dry_run] || archive.empty?
    abort "Generate repository, formula history and release data first"
  end

  puts "Dry run: committed history is valid; generate fresh reports to append a year."
  exit
end

reports.each do |name, report|
  abort "#{name}: generated report is missing" unless report
  abort "#{name}: formula history backfill is incomplete" if name == "formula-history" && !report.fetch("complete")
  if Time.iso8601(report.fetch("generated_at")).year <= year
    abort "#{name}: regenerate after the end of #{year} before freezing it"
  end

  # Keep published years immutable; corrections require an explicit edit to the archive.
  previous = archive.fetch(name, {})
  cutoff = previous.fetch("through_year", 0)
  next if cutoff == year

  years = ((cutoff.zero? ? report.fetch("start_year", 2009) : cutoff+1)..year)
  annual_rows = lambda do |rows, label|
    rows = rows.select { |row| years.cover?(row.fetch("period").to_i) }
    years.each do |required_year|
      abort "#{label}: missing #{required_year}" unless rows.any? { |row| row.fetch("period") == required_year.to_s }
    end
    rows
  end

  frozen = report.slice("source", "revision", "generated_at", "start_year", "platforms")
  frozen["through_year"] = year
  case name
  when "github"
    frozen["security_disclosures"] = report.fetch("security_disclosures", []).select do |post|
      post.fetch("date").to_i <= year
    end
    frozen["security_disclosures"].unshift(*previous.fetch("security_disclosures", []))
    frozen["security_disclosures"].uniq! { |post| post.fetch("url") }
    frozen["maintainer_history"] = previous["maintainer_history"] if previous["maintainer_history"]
    frozen["repositories"] = report.fetch("repositories").to_h do |repository, data|
      rows = annual_rows.call(data.fetch("rows"), repository)
      rows.each do |row|
        fetched = row["github_fetched_at"]
        if fetched && Time.iso8601(fetched) < Time.utc(row.fetch("period").to_i + 1)
          abort "#{repository}: #{row.fetch("period")} counts were collected before the year ended"
        end
      end
      rows.concat(previous.dig("repositories", repository, "rows") || [])
      [repository, previous.fetch("repositories", {}).fetch(repository, {}).merge(data).merge("rows" => rows)]
    end
    frozen["repositories"] = previous.fetch("repositories", {}).merge(frozen.fetch("repositories"))
    combined = report.fetch("combined_contributors")
    rows = annual_rows.call(combined.fetch("rows"), "Combined contributors")
    frozen["combined_contributors"] = combined.merge(
      "rows" => rows + (previous.dig("combined_contributors", "rows") || []),
    )
  when "formula-history"
    frozen["historical_backfill"] = report["historical_backfill"] if report["historical_backfill"]
    rows = annual_rows.call(report.fetch("rows"), "Formula history")
    frozen["rows"] = rows + previous.fetch("rows", [])
  when "releases"
    frozen.delete("revision") # Each release records its exact tag and predecessor revisions.
    rows = annual_rows.call(report.fetch("years"), "Releases")
    frozen["years"] = rows + previous.fetch("years", [])
    %w[releases aggregates].each do |key|
      frozen[key] = report.fetch(key).select { |row| years.cover?(row.fetch("date")[0, 4].to_i) } +
                    previous.fetch(key, [])
    end
  end
  archive[name] = frozen
end

json = "#{JSON.pretty_generate(archive)}\n"
if options[:dry_run]
  puts "Dry run: #{json.bytesize} bytes through #{year}; " \
       "#{(output.exist? && output.read == json) ? "unchanged" : "would update"}."
else
  output.dirname.mkpath
  output.write(json)
  puts "Wrote #{output}: #{json.bytesize} bytes through #{year}."
end
