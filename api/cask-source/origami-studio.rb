cask "origami-studio" do
  version "102.0.0.11.230,332296095"
  sha256 :no_check

  url "https://facebook.com/designtools/origami/",
      verified: "facebook.com/designtools/"
  name "Origami Studio"
  desc "Design, animate, and prototype design tool from Facebook"
  homepage "https://origami.design/"

  livecheck do
    url "https://m.facebook.com/mobile_builds/appcast.xml?app_id=892075810923571&amp;amp%3Bflavor=production"
    strategy :sparkle
  end

  depends_on macos: ">= :sierra"

  app "Origami Studio.app"
end
