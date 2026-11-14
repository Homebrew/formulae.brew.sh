#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "time"

abort "Usage: #{$PROGRAM_NAME} FEED.json ..." if ARGV.empty?

ARGV.each do |path|
  feeds = JSON.parse(File.read(path))
  { "new" => 50, "updated" => 500 }.each do |type, count|
    entries = feeds.fetch(type)
    if !entries.is_a?(Array) || entries.length != count
      abort "Expected #{count} #{type} entries in #{path}"
    end
    if entries.map { |entry| entry.fetch("id") }.uniq.length != count
      abort "Duplicate #{type} entry identifiers in #{path}"
    end

    entries.each do |entry|
      %w[id name commit].each do |field|
        if !entry[field].is_a?(String) || entry[field].empty?
          abort "Missing or empty #{field} in #{path}"
        end
      end
      Time.iso8601(entry.fetch("date"))
      if !entry["versions"].is_a?(Array) || !entry["versions"].all?(String)
        abort "Invalid versions in #{path}"
      end
    end
  end
end
