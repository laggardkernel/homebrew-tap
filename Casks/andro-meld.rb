cask "andro-meld" do
  version "0.0.2"

  url "https://andromeld.catchingnow.com/dmg/AndroMeld_v#{version}.dmg"
  name "AndroMeld"
  desc "Seamlessly connected your Mac and Android devices"
  homepage "https://andromeld.catchingnow.com/"

  livecheck do
    url "https://andromeld.catchingnow.com/"
    regex(%r{href=".*?/dmg/AndDrive_v?(\d+(?:\.\d+)+).dmg"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  auto_updates false
  depends_on macos: ">= :sequoia"

  app "AndroMeld.app"

  uninstall quit: "com.catchingnow.andfiles"

  zap trash: [
    "~/Library/Application Scripts/com.catchingnow.andfiles",
    "~/Library/Application Scripts/com.catchingnow.andfiles.fileproviderextension",
    "~/Library/Application Scripts/com.catchingnow.andfiles.thumbnailextension",
    "~/Library/Application Scripts/group.com.catchingnow.andfiles.shared",
    "~/Library/Application Support/com.catchingnow.andfiles",
    "~/Library/Caches/com.catchingnow.andfiles",
    "~/Library/Containers/com.catchingnow.andfiles",
    "~/Library/Containers/com.catchingnow.andfiles.fileproviderextension",
    "~/Library/Containers/com.catchingnow.andfiles.thumbnailextension",
    "~/Library/Group Containers/group.com.catchingnow.andfiles.shared",
    "~/Library/Preferences/com.catchingnow.andfiles.plist",
  ]
end
