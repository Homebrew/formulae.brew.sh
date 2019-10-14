#!/usr/bin/env brew ruby
os = ARGV.first

if os == "mac"
  formula_dir = formula_filename = "formula"
elsif os == "linux"
  formula_dir = "formula-linux"
  formula_filename = "formula_linux"
end

directories = ["_data/#{formula_dir}", "api/#{formula_dir}", "#{formula_dir}"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

json_template = IO.read "_api_#{formula_filename}.json.in"
html_template = IO.read "_#{formula_filename}.html.in"

CoreTap.instance.formula_names.each do |n|
  f = Formulary.factory(n)
  IO.write("_data/#{formula_dir}/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash)}\n")
  IO.write("api/#{formula_dir}/#{f.name}.json", json_template)
  IO.write("#{formula_dir}/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
end
