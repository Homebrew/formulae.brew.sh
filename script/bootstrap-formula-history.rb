#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"
require "tempfile"

checkpoint = Pathname(ARGV.fetch(0))
exit if checkpoint.size?

checkpoint.dirname.mkpath
Tempfile.create(["formula-history", ".json"], checkpoint.dirname) do |download|
  system "curl", "--fail", "--location", "--retry", "3", "--proto", "=https", "--proto-redir", "=https",
         "--output", download.path,
         "https://github.com/user-attachments/files/34146353/formula-history-cache.json", exception: true
  unless Digest::SHA256.file(download.path).hexdigest == "e615bec06c2112230e4c5cee0c317fb9fc885733d3123ae74b14824fbb6d79ac"
    abort "Formula history checkpoint checksum mismatch"
  end

  data = JSON.parse(File.read(download.path))
  %w[signature start_year baseline seeded head packages years].each { |key| data.fetch(key) }
  abort "Incomplete formula history checkpoint" unless data.fetch("seeded") && !data.fetch("head").empty?

  history = JSON.parse(File.read("analytics/history.json")).fetch("formula-history")
  checkpoint_year = data.fetch("years").keys.map(&:to_i).max
  history.fetch("rows").each do |row|
    next if row.fetch("period").to_i >= checkpoint_year

    data.fetch("years")[row.fetch("period")] = row.except("period", "formulae")
  end
  history.fetch("historical_backfill").fetch("recovered_versions", {}).each do |path, versions|
    package = data.fetch("packages").fetch(path)
    package["versions"] |= versions
  end
  File.write(download.path, JSON.generate(data))
  File.rename(download.path, checkpoint)
end
