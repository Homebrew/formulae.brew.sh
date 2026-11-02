# frozen_string_literal: true

# Browsable links for formula patches.
module PatchFilters
  COMMIT_PATCH_URL = %r{\A(?<page>https?://[^/]+/.+/(?:commit|compare)/[^/?]+?)\.(?:diff|patch)(?:\?.*)?\z}

  def patch_url(url)
    COMMIT_PATCH_URL.match(url)&.[](:page) || url
  end
end

Liquid::Template.register_filter(PatchFilters)
