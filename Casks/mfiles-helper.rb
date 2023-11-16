cask "mfiles-helper" do
  version "2.5.0,20231115"
  # sha256 ""

  url "http://mfiles.maokebing.com/package/mfiles-helper-#{version.before_comma}-macos-#{version.after_comma}.dmg"
  name "MFiles Helper"
  desc "Sharing files easily within local network"
  homepage "https://mfiles.maokebing.com/"

  livecheck do
    url "https://mfiles.maokebing.com/"
    regex(/href=['"](package\/)?mfiles[._-]helper[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-](\d+)\.dmg/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match&.second + "," + match&.third
      end
    end
  end

  auto_updates false
  # depends_on macos: ">= :10.10"

  # Name was changed from "MFiles Helper.app" to "爱传送.app" in 2.2.1
  app "爱传送.app", target: "MFiles Helper.app"

  zap trash: [
    "~/Library/Preferences/com.windtune.itransfer.plist",
  ]
end
