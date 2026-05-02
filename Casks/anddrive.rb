cask "anddrive" do
  version "0.0.1"

  url "https://anddrive.catchingnow.com/dmg/AndDrive_v#{version}.dmg"
  name "AndDrive"
  desc "Seamlessly connected your Mac and Android devices"
  homepage "https://anddrive.catchingnow.com/"

  livecheck do
    url "https://anddrive.catchingnow.com/"
    regex(%r{href=".*?/dmg/AndDrive_v?(\d+(?:\.\d+)+).dmg"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  auto_updates false
  depends_on macos: ">= :sequoia"

  app "AndDrive.app"

  uninstall quit: "com.catchingnow.andfiles"

  zap trash: [
    "~/Library/Application Support/com.catchingnow.andfiles",
    "~/Library/Caches/com.catchingnow.andfiles",
    "~/Library/Preferences/com.catchingnow.andfiles.plist",
  ]
end
