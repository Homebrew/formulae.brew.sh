#!/usr/bin/env brew ruby
require 'cask/cask'
directories = ["_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

Cask::Cask.each do |c|
  json_filename = "#{c.token}.json"
  IO.write("_data/cask/#{json_filename}", JSON.pretty_generate(c.to_h))
  File.open("_data/cask/#{json_filename}",'a') { |f| f.write("\n") }
  FileUtils.cp "_api_cask.json.in", "api/cask/#{json_filename}"
end
