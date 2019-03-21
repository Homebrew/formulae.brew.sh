#!/usr/bin/env brew ruby
require 'cask/cask'
directories = ["_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

Tap.default_cask_tap.cask_files.each do |p|
  c = Cask::CaskLoader::FromPathLoader.new(p).load
  json_filename = "#{c.token}.json"
  IO.write("_data/cask/#{json_filename}", "#{JSON.pretty_generate(c.to_h)}\n")
  FileUtils.cp "_api_cask.json.in", "api/cask/#{json_filename}"

  html = IO.read "_cask.html.in"
  html.gsub!("title: $TITLE", "title: \"#{c.token}\"")
  IO.write("cask/#{c.token}.html", html)
end
