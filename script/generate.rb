#!/usr/bin/env brew ruby
os = ARGV.first

formula_dir = os == "mac" ? "formula" : "formula-linux"

directories = ["_data/#{formula_dir}", "api/#{formula_dir}", "#{formula_dir}"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula.json.in"
html_template = IO.read "_formula.html.in"

CoreTap.instance.formula_names.each do |n|
  f = Formulary.factory(n)
  IO.write("_data/#{formula_dir}/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash)}\n")
  IO.write("api/#{formula_dir}/#{f.name}.json", json_template)
  IO.write("#{formula_dir}/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
end
