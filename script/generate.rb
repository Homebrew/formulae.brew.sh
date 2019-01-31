#!/usr/bin/env brew ruby
directories = ["_data/formula", "api/formula", "formula"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

formulae_indexes = []
Formula.each do |f|
  json_filename = "#{f.name}.json"
  IO.write("_data/formula/#{json_filename}", JSON.pretty_generate(f.to_hash))
  FileUtils.cp "_api_formula.json.in", "api/formula/#{json_filename}"

  html = IO.read "_formula.html.in"
  html.gsub!("title: $TITLE", "title: #{f.name}")
  IO.write("formula/#{f.name}.html", html)
  formulae_indexes << f.to_hash unless ENV["HOMEBREW_ALGOLIA_API_KEY"]
end

if ENV["HOMEBREW_ALGOLIA_API_KEY"]
  Homebrew.install_gem! 'algoliasearch'
  require 'algoliasearch'
  Algolia.init(application_id: 'LV7WOXOQ3N',
               api_key:        ENV["HOMEBREW_ALGOLIA_API_KEY"])
  index = Algolia::Index.new('formulae')
  index.clear_index()
  index.add_objects(formulae_indexes)
end