#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "time"
require "uri"

api_url = ARGV.fetch(0)

fetch = lambda do |url, *options|
  body, status = Open3.capture2(
    "curl", "--fail", "--location", "--silent", "--show-error", "--compressed", "--max-time", "15", *options, url
  )
  raise IOError, "Could not fetch #{url}" unless status.success?

  body
end

tags = JSON.parse(fetch.call(URI.join(api_url, "internal-package-tags.json").to_s))
unless tags.is_a?(Array) && !tags.empty? && tags.all? { |tag| tag.is_a?(String) && /\A[a-z0-9_]+\z/.match?(tag) }
  abort "Invalid package tag index"
end

cutoff = Time.now.utc.floor - 3600
failed = tags.filter_map do |tag|
  name = "packages.#{tag}.jws.json"
  url = URI.join(api_url, "internal/#{name}").to_s
  begin
    # Both the signed payload and its metadata come first in today's format.
    # The first KiB usually suffices to read the timestamp.
    generated_at = begin
      prefix = fetch.call(url, "--range", "0-1023")
      # Only extract a complete flat object, and match bytes in case the range splits a character.
      metadata = prefix.b[/\A\{"payload":"\{\\"metadata\\":(\{[^{}]*\})[,}]/, 1]
      JSON.parse(JSON.parse("\"#{metadata}\""))["generated_at"] if metadata
    rescue IOError, JSON::ParserError
      nil
    end
    generated_at ||= begin
      payload = JSON.parse(fetch.call(url)).fetch("payload")
      JSON.parse(payload).fetch("metadata").fetch("generated_at")
    end
    published = Time.at(generated_at).utc
    next if published >= cutoff

    warn "#{name}: generated at #{published.iso8601}, expected #{cutoff.iso8601} or later"
  rescue => e
    warn "#{name}: #{e.message}"
  end
  name
end
exit if failed.empty?

if (output = ENV.fetch("GITHUB_OUTPUT", nil))
  File.open(output, "a") { |file| file.puts "failed_packages=#{failed.join(", ")}" }
end
exit 1
