#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "prune-analytics"

%w[
  install/30d
  github-packages/30d
  github/history
  releases/history
  formula-history/history
].each do |report|
  %w[_data api].each do |prefix|
    path = Pathname("#{prefix}/analytics/#{report}.json")
    abort "Missing or empty analytics report: #{path}" unless path.size?
  end
end
