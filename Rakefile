require "rake"
require "rake/clean"

task default: :jekyll

task :deps do
  sh "brew", "ruby", "script/generate.rb"
end

task jekyll: :deps do
  sh "bundle", "exec", "jekyll", "build"
end

CLEAN.include FileList["_site"]
