# frozen_string_literal: true

require "jekyll"
require_relative "../_plugins/patches"

RSpec.describe PatchFilters do
  subject(:filters) { Object.new.extend(described_class) }

  describe "#patch_url" do
    it "links GitHub commit patches to the commit page" do
      expect(filters.patch_url("https://github.com/Cisco-Talos/clamav/commit/729eaef96263970dede0808426374bb0597dae90.patch?full_index=1"))
        .to eq("https://github.com/Cisco-Talos/clamav/commit/729eaef96263970dede0808426374bb0597dae90")
    end

    it "links GitLab commit diffs to the commit page" do
      expect(filters.patch_url("https://gitlab.com/gnutls/gnutls/-/commit/29c2027c963cf559817d0da37c1fc2efd0c1bd6a.diff"))
        .to eq("https://gitlab.com/gnutls/gnutls/-/commit/29c2027c963cf559817d0da37c1fc2efd0c1bd6a")
    end

    it "links comparison patches to the comparison page" do
      expect(filters.patch_url("https://github.com/hexagonal-sun/bic/compare/631cfb449eec35a2df52eb317f4e9add33c1dea9..7748c44eed2c53ce82b9d45a9f629f68f8cc4f99.patch"))
        .to eq("https://github.com/hexagonal-sun/bic/compare/631cfb449eec35a2df52eb317f4e9add33c1dea9..7748c44eed2c53ce82b9d45a9f629f68f8cc4f99")
    end

    it "leaves patch files in a commit directory alone" do
      url = "https://raw.githubusercontent.com/org/repo/main/commit/fix.patch"
      expect(filters.patch_url(url)).to eq(url)
    end

    it "leaves other patch URLs alone" do
      url = "https://bugs.gentoo.org/attachment.cgi?id=916782"
      expect(filters.patch_url(url)).to eq(url)
    end
  end
end
