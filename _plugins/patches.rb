# frozen_string_literal: true

# Browsable links for formula patches.
module PatchFilters
  COMMIT_PATCH_URL = %r{
    \A(?<page>https?://[^/]+/.+/(?:commit/\h{7,40}|compare/[^/?]+?\.{2,3}[^/?]+?))\.(?:diff|patch)(?:\?.*)?\z
  }x

  def patch_url(url)
    COMMIT_PATCH_URL.match(url)&.[](:page) || url
  end
end

Liquid::Template.register_filter(PatchFilters)
