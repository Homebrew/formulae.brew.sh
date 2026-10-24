#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "pathname"

# Usage reports remain rolling snapshots.
Pathname.glob("_data/analytics/**/*d.json").each do |path|
  data = JSON.parse(path.read)
  start_date = Date.iso8601(data.fetch("start_date"))
  end_date = Date.iso8601(data.fetch("end_date"))
  next if (end_date - start_date) <= 365 && end_date >= Time.now.utc.to_date - 365

  warn "Removing expired usage report: #{path}"
  path.delete
  api = Pathname(path.to_s.sub("_data/", "api/"))
  api.delete if api.exist?
end
