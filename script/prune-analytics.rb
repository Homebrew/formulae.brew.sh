#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "pathname" # rubocop:disable Lint/RedundantRequireStatement -- Local pruning may use Ruby < 4.
require "time"

# Usage reports remain rolling snapshots, never part of the committed history archive.
Pathname.glob("_data/analytics/**/*d.json").each do |path|
  data = JSON.parse(path.read)
  if path.to_s.include?("/github-packages/")
    next if data.fetch("formulae").each_value.all? do |formula|
      Time.iso8601(formula.fetch("fetched_at")).utc.to_date >= Time.now.utc.to_date - 365
    end
  else
    start_date = Date.iso8601(data.fetch("start_date"))
    end_date = Date.iso8601(data.fetch("end_date"))
    next if (end_date - start_date) <= 365 && end_date >= Time.now.utc.to_date - 365
  end

  warn "Removing expired usage report: #{path}"
  path.delete
  api = Pathname(path.to_s.sub("_data/", "api/"))
  api.delete if api.exist?
end
