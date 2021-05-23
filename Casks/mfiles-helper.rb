cask "mfiles-helper" do
  version "2.1.0"
  # sha256

  url "http://mfiles.maokebing.com/mfiles-helper-2.1.0-macos-20092601.dmg"
  name "MFiles Helper"
  desc "Sharing files easily within local network"
  homepage "http://mfiles.maokebing.com/"

  livecheck do
    url "http://mfiles.maokebing.com/"
    regex(/href=['"]?mfiles[._-]helper[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-].+?['"]?/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq
    end
  end

  auto_updates false
  depends_on macos: ">= :yosemite"

  app "MFiles Helper.app"

  zap trash: [
    "/Users/wyh/Library/Preferences/com.windtune.itransfer.plist",
  ]
end
