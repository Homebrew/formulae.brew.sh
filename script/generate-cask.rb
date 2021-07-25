#!/usr/bin/env brew ruby
require "cask/cask"

tap_name = ARGV.first
tap = Tap.fetch(tap_name)

directories = ["_data/cask", "api/cask", "api/cask-source", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

json_template = IO.read "_api_cask.json.in"
html_template = IO.read "_cask.html.in"

tap.cask_files.each do |p|
  c = Cask::CaskLoader.load(p)
  IO.write("_data/cask/#{c.token}.json", "#{JSON.pretty_generate(c.to_h)}\n")
  IO.write("api/cask/#{c.token}.json", json_template)
  IO.write("api/cask-source/#{c.token}.rb", p.read)
  IO.write("cask/#{c.token}.html", html_template.gsub("title: $TITLE", "title: \"#{c.token}\""))
end
