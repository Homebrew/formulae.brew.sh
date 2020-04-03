#!/usr/bin/env brew ruby
require "cask/cask"

tap_name = (ARGV.first || "").split("/")
tap = tap_name.empty? ? Tap.default_cask_tap : Tap.new(*tap_name)

directories = ["_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

json_template = IO.read "_api_cask.json.in"
html_template = IO.read "_cask.html.in"

tap.cask_files.each do |p|
  c = Cask::CaskLoader::FromPathLoader.new(p).load
  IO.write("_data/cask/#{c.token}.json", "#{JSON.pretty_generate(c.to_h)}\n")
  IO.write("api/cask/#{c.token}.json", json_template)
  IO.write("cask/#{c.token}.html", html_template.gsub("title: $TITLE", "title: \"#{c.token}\""))
end
