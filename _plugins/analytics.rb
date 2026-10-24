# frozen_string_literal: true

# Analytics table formatting and ordering shared by the site.
module AnalyticsFilters
  def number_with_delimiter(input)
    integer, decimal = input.to_s.split(".", 2)
    [integer.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,'), decimal].compact.join(".")
  end
end

Liquid::Template.register_filter(AnalyticsFilters)
