cask "rsyncosx-versioned" do
  on_mojave :or_older do
    version "6.4.2"
    # Backup of the bugfix 6.4.2
    url "https://pseudocold.com/app/rsyncosx/RsyncOSX.#{version}-1949.dmg"
    sha256 "7dae24b128986b4140efb9e4c264de5a597097c313565edf9275bea1d58bae5a"
    # sha256 of the GH release 6.4.2
    # sha256 "7e2e044aee98a53b03730a978866939ab919afa2e3997fbfb9632162418f6a5a"
  end
  on_catalina :or_newer do
    version "6.5.8"
    url "https://pseudocold.com/app/rsyncosx/RsyncOSX.#{version}.dmg"
    sha256 "4f23be29b260a93e05a2b9abf2ac42419b918b455e664d12ed92663ee008ad4e"
  end

  name "RsyncOSX"
  desc "GUI for rsync"
  homepage "https://github.com/rsyncOSX/RsyncOSX"

  livecheck do
    skip "Legacy version"
  end

  app "RsyncOSX.app"

  zap trash: [
    "~/Library/Caches/no.blogspot.RsyncOSX",
    "~/Library/Preferences/no.blogspot.RsyncOSX.plist",
    "~/Library/Saved Application State/no.blogspot.RsyncOSX.savedState",
  ]
end
# https://rsyncosx.netlify.app/post/changelog/
