#!/usr/bin/env brew ruby
FileUtils.mkdir_p(["_data/formula", "api/formula", "formula"])

Formula.each do |f|
  json_filename = "#{f.name}.json"
  IO.write("_data/formula/#{json_filename}", JSON.pretty_generate(f.to_hash))
  FileUtils.cp "_api_formula.json.in", "api/formula/#{json_filename}"

  html = IO.read "_formula.html.in"
  html.gsub!("title: $TITLE", "title: #{f.name}")
  IO.write("formula/#{f.name}.html", html)
end
