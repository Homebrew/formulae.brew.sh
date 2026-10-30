# frozen_string_literal: true

require "json"
require "optparse"
require "tempfile"
require "time"
require "utils/analytics/formula_history"

# Collects bounded feeds from first-parent history, without a persistent checkpoint.
class FormulaFeeds
  LIMITS = { "new" => 50, "updated" => 500 }.freeze

  def initialize(repository, revision: "HEAD", limits: LIMITS)
    @history = Utils::Analytics::FormulaHistory.new(Pathname(repository))
    @revision = @history.git("rev-parse", "--verify", "#{revision}^{commit}")
    @limits = limits
    @builds = {}
  end

  def generate
    if @history.git("rev-parse", "--is-shallow-repository") == "true"
      raise "Formula feeds require complete Git history; unshallow the core checkout first"
    end

    feeds = @limits.to_h { |name, _limit| [name, []] }
    offset = 0
    until feeds.all? { |name, entries| entries.length >= @limits.fetch(name) }
      changes = changes(offset)
      break if changes.nil?

      selected = changes.select do |change|
        feed = change.fetch(:added) ? "new" : "updated"
        feeds.fetch(feed).length < @limits.fetch(feed)
      end
      blobs = selected.flat_map { |change| [change[:before], change.fetch(:after)] }.compact.uniq
      sources = blobs.empty? ? {} : @history.sources(blobs)
      selected.each do |change|
        feed = change.fetch(:added) ? "new" : "updated"
        next if feeds.fetch(feed).length >= @limits.fetch(feed)

        after = builds(change.fetch(:path), change.fetch(:after), sources)
        before = change.fetch(:added) ? nil : builds(change.fetch(:old_path), change.fetch(:before), sources)
        next if before && after.none? do |platform, build|
          old = before.fetch(platform)
          old.version && build.version && (old.version != build.version || build.revision > old.revision)
        end

        feeds.fetch(feed) << {
          "id"       => "#{change.fetch(:commit)}:#{change.fetch(:path)}",
          "name"     => File.basename(change.fetch(:path), ".rb"),
          "date"     => Time.at(change.fetch(:timestamp)).utc.iso8601,
          "commit"   => change.fetch(:commit),
          "versions" => after.values.filter_map do |build|
            next unless build.version

            build.revision.positive? ? "#{build.version}_#{build.revision}" : build.version
          end.uniq,
        }
      end
      offset += 100
    end
    { "revision" => @revision, **feeds }
  end

  def builds(path, blob, sources)
    @builds[[path, blob]] ||= @history.builds(path, sources.fetch(blob)).tap do |builds|
      if builds.values.any?(&:error)
        raise "Cannot read formula metadata for #{path} at #{blob}"
      end
    end
  end

  def changes(offset)
    output = @history.git("log", @revision, "--first-parent", "--raw", "--root", "--no-abbrev",
                          "--diff-merges=first-parent", "--find-renames=50%", "--max-count=100", "--skip=#{offset}",
                          "--format=%x00commit%x00%H%x00%ct", "-z")
    return if output.empty?

    tokens = output.split("\0")
    result = []
    deleted = {}
    commit = timestamp = nil
    while (token = tokens.shift)
      if token == "commit"
        commit = tokens.shift
        timestamp = Integer(tokens.shift, 10)
      elsif token.lstrip.start_with?(":")
        old_mode, mode, before, after, status = token.lstrip.delete_prefix(":").split
        old_path = tokens.shift
        path = status.start_with?("R", "C") ? tokens.shift : old_path
        if status == "D" && %w[100644 100755].include?(old_mode) && @history.formula_path?(old_path)
          deleted[[commit, File.basename(old_path)]] = { old_path:, before:, added: false }
        end
        next if %w[100644 100755].exclude?(mode) || !@history.formula_path?(path)

        added = %w[100644 100755].exclude?(old_mode) || !@history.formula_path?(old_path)
        result << { commit:, timestamp:, path:, old_path:, before: added ? nil : before, after:, added: }
      end
    end
    result.each do |change|
      next unless change.fetch(:added)

      previous = deleted[[change.fetch(:commit), File.basename(change.fetch(:path))]]
      change.merge!(previous) if previous
    end
    result
  end
end

options = { repository: CoreTap.instance.path, revision: "HEAD", output: Pathname("_data/formula_feeds.json") }
OptionParser.new do |parser|
  parser.banner = "Usage: brew generate-formula-feeds [options]"
  parser.on("--repository PATH") { |path| options[:repository] = Pathname(path) }
  parser.on("--revision REVISION") { |revision| options[:revision] = revision }
  parser.on("--output PATH") { |path| options[:output] = Pathname(path) }
end.parse!
feeds = FormulaFeeds.new(options.fetch(:repository), revision: options.fetch(:revision)).generate
output = options.fetch(:output)
output.dirname.mkpath
Tempfile.create([output.basename.to_s, ".tmp"], output.dirname) do |temporary|
  temporary.write("#{JSON.pretty_generate(feeds)}\n")
  temporary.close
  File.rename(temporary.path, output)
end
puts "Generated #{feeds.fetch("new").length} new and #{feeds.fetch("updated").length} updated formula entries"
