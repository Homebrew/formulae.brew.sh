# frozen_string_literal: true

# Analytics table formatting and ordering shared by the site.
module AnalyticsFilters
  def analytics_report(data, category)
    return data unless data && category == "github"

    repositories = data.fetch("repositories").transform_values do |repository|
      repository.merge("rows" => repository.fetch("rows").map do |row|
        opened = row["pull_requests_opened"]
        merged = row["pull_requests_merged"]
        merged = [merged, opened].min if opened && merged
        row.merge("pull_requests_merged" => merged, "merge_rate" => if opened&.positive? && merged
          (100.0 * merged / opened).round(1)
        end)
      end)
    end
    rows = data.fetch("combined_contributors").fetch("rows").map do |row|
      snapshots = repositories.values.filter_map do |repository|
        repository.fetch("rows").find { |snapshot| snapshot.fetch("period") == row.fetch("period") }
      end
      maintainers = snapshots.filter_map { |snapshot| snapshot["maintainers"] }.first
      row.merge(
        "maintainers" => maintainers,
        "maintainer_contributor_ratio" => if maintainers && row.fetch("contributors").positive?
          (100.0 * maintainers / row.fetch("contributors")).round(2)
        end,
        "pull_requests_per_maintainer" => if maintainers&.positive?
          (snapshots.sum { |snapshot| snapshot.fetch("pull_requests_opened", 0) }.to_f / maintainers).round(2)
        end,
        "issues_per_maintainer" => if maintainers&.positive?
          (snapshots.sum { |snapshot| snapshot.fetch("issues_opened", 0) }.to_f / maintainers).round(2)
        end,
      )
    end
    data.merge(
      "repositories" => repositories,
      "combined_contributors" => data.fetch("combined_contributors").merge("rows" => rows),
    )
  end

  def number_with_delimiter(input)
    integer, decimal = input.to_s.split(".", 2)
    [integer.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), decimal].compact.join(".")
  end

  def nonzero_columns(rows, columns)
    rows = [rows] if rows.is_a?(Hash)
    columns.select do |column|
      rows.any? do |row|
        value = row.fetch(column, 0)
        value.nil? || value.to_s.delete(",").to_f != 0
      end
    end
  end

  def sort_by_downloads(formulae)
    formulae.sort_by { |name, row| [-row.fetch("all_time"), name] }
  end
end

Liquid::Template.register_filter(AnalyticsFilters)
