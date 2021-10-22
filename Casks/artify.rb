cask "artify" do
  version "1.0"
  # sha256 ""

  url "https://github.com/NghiaTranUIT/artify-macos/releases/download/#{version}/Artify_#{version}.dmg",
      verified: "github.com/NghiaTranUIT/artify-macos/"
  name "Artify"
  desc "🌎 18th century Arts for everyone"
  homepage "https://artify.launchaco.com/"

  livecheck do
    url "https://github.com/NghiaTranUIT/artify-macos/releases/"
    strategy :github_release
  end

  app "Artify.app"

  zap trash: [
    "~/Library/Application Support/com.art.Artify",
    "~/Library/Caches/Artify",
    "~/Library/Caches/com.art.Artify",
    "~/Library/Preferences/com.art.Artify.plist",
  ]
end
