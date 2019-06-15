#!/usr/bin/env brew ruby
directories = ["_data/formula-linux", "api/formula-linux", "formula-linux"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula_linux.json.in"
html_template = IO.read "_formula_linux.html.in"

CoreTap.instance.formula_names.each do |n|
  f = Formulary.factory(n)
  IO.write("_data/formula-linux/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash)}\n")
  IO.write("api/formula-linux/#{f.name}.json", json_template)
  IO.write("formula-linux/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
end
