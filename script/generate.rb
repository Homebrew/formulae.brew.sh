#!/usr/bin/env brew ruby
os = ARGV.first
tap_name = ARGV.second

formula_dir = os == "mac" ? "formula" : "formula-linux"
tap = Tap.fetch(tap_name)

directories = ["_data/#{formula_dir}", "api/#{formula_dir}", "#{formula_dir}"]
FileUtils.rm_rf directories + ["_data/#{formula_dir}_canonical.json"]
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula.json.in"
html_template = IO.read "_formula.html.in"

tap.formula_names.each do |n|
  f = Formulary.factory(n)
  IO.write("_data/#{formula_dir}/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash)}\n")
  IO.write("api/#{formula_dir}/#{f.name}.json", json_template)
  IO.write("#{formula_dir}/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
end
IO.write("_data/#{formula_dir}_canonical.json", "#{JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))}\n")
