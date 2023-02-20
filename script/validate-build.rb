#!/usr/bin/env ruby

require "pathname"

Dir.chdir Pathname(__dir__).parent

error = false

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

abort if error
