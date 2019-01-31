#!/usr/bin/env brew ruby
require 'cask/cask'
directories = ["_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

cask_indexes = []
Cask::Cask.each do |c|
  json_filename = "#{c.token}.json"
  IO.write("_data/cask/#{json_filename}", JSON.pretty_generate(c.to_h))
  FileUtils.cp "_api_cask.json.in", "api/cask/#{json_filename}"
  cask_indexes << c.to_h unless ENV["HOMEBREW_ALGOLIA_API_KEY"]
end

if ENV["HOMEBREW_ALGOLIA_API_KEY"]
  Homebrew.install_gem! 'algoliasearch'
  require 'algoliasearch'
  Algolia.init(application_id: 'LV7WOXOQ3N',
               api_key:        ENV["HOMEBREW_ALGOLIA_API_KEY"])
  index = Algolia::Index.new('casks')
  index.clear_index()
  index.add_objects(cask_indexes)
end