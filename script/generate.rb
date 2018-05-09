#!/usr/bin/env brew ruby
FileUtils.mkdir_p(["_data/formulae", "api/formulae", "formulae"])

Formula.each do |f|
  json_filename = "#{f.name}.json"
  IO.write("_data/formulae/#{json_filename}", JSON.pretty_generate(f.to_hash))
  FileUtils.cp "_api_formulae.json.in", "api/formulae/#{json_filename}"

  html = IO.read "_formulae.html.in"
  html.gsub!("title: $TITLE", "title: #{f.name}")
  IO.write("formula/#{f.name}.html", html)
end
