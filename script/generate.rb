#!/usr/bin/env brew ruby
require 'cask/cask'
directories = ["_data/formula", "api/formula", "formula", "_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

Formula.each do |f|
  json_filename = "#{f.name}.json"
  IO.write("_data/formula/#{json_filename}", JSON.pretty_generate(f.to_hash))
  FileUtils.cp "_api_formula.json.in", "api/formula/#{json_filename}"

  html = IO.read "_formula.html.in"
  html.gsub!("title: $TITLE", "title: #{f.name}")
  IO.write("formula/#{f.name}.html", html)
end

Cask::Cask.each do |c|
  json_filename = "#{File.basename(c.sourcefile_path,'.rb')}.json"
  IO.write("_data/cask/#{json_filename}", JSON.pretty_generate(c.to_h))
  FileUtils.cp "_api_formula.json.in", "api/cask/#{json_filename}"

  # TODO: generate cask html template and output(s)
  # html = IO.read "_formula.html.in"
  # html.gsub!("title: $TITLE", "title: #{c.name}")
  # IO.write("cask/#{c.name}.html", html)
end
