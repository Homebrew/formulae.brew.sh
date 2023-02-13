#!/usr/bin/env brew ruby
tap_name = ARGV.first
tap = Tap.fetch(tap_name)

directories = ["_data/formula", "api/formula", "formula"]
FileUtils.rm_rf directories + ["_data/formula_canonical.json"]
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula.json.in"
html_template = IO.read "_formula.html.in"

Formulary.enable_factory_cache!

tap.formula_names.each do |n|
  f = Formulary.factory(n)
  IO.write("_data/formula/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash_with_variations)}\n")
  IO.write("api/formula/#{f.name}.json", json_template)
  IO.write("formula/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
end
IO.write("_data/formula_canonical.json", "#{JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))}\n")
