cask "mellow" do
  version "0.1.10"
  sha256 "a8eb548a2dc77179aa6bdf2db735eaa9eeb1abdc2b4e77c42be0756ddc274e42"

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
