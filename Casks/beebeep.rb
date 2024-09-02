cask "beebeep" do
  version "5.8.5"

  url "https://downloads.sourceforge.net/beebeep/MacOSX/beebeep-#{version}-osx.zip",
      verified: "sourceforge.net/beebeep/"
  name "BeeBEEP"
  desc "Secure peer to peer office messenger"
  homepage "https://www.beebeep.net/"

  livecheck do
    url "https://sourceforge.net/projects/beebeep/rss?path=/MacOSX"
    strategy :page_match
    regex(/beebeep-(\d+(?:\.\d+)+)-.+?\.dmg/i)
  end

  auto_updates true
  depends_on macos: ">= :sierra"

  app "BeeBEEP.app"

  zap trash: [
    "~/Library/Application Support/BeeBEEP", # non-existing yet
    "~/Library/Application Support/MarcoMastroddiSW",
    "~/Library/Preferences/net.beebeep.plist",
    "~/Library/Saved Application State/net.beebeep.savedState",
  ]
end
