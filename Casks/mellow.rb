cask "mellow" do
  version "0.1.12"
  sha256 "f42939b1dd6e870c1d511b99070e789a0062aa98e0cb3f1eadea6bfe60cdefe2"

  url "https://github.com/mellow-io/mellow/releases/download/v#{version}/Mellow-#{version}.dmg"
  appcast "https://github.com/mellow-io/mellow/releases.atom"
  name "Mellow"
  homepage "https://github.com/mellow-io/mellow"

  app "Mellow.app"

  zap trash: [
    "~/Library/Application Support/Mellow",
    "~/Library/Preferences/org.mellow.mellow.plist",
    "~/Library/Logs/Mellow",
  ]
end
