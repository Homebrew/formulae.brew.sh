#!/usr/bin/env brew ruby
require 'cask/cask'
directories = ["_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

Cask::Cask.each do |c|
  json_filename = "#{File.basename(c.sourcefile_path,'.rb')}.json"
  IO.write("_data/cask/#{json_filename}", JSON.pretty_generate(c.to_h))
  FileUtils.cp "_api_formula.json.in", "api/cask/#{json_filename}"
end
