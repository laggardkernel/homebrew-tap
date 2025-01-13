cask "doubao" do
  version "1.39.3"

  # .dmg from webpage download, .zip from check update API.
  # url "https://lf-flow-web-cdn.doubao.com/obj/flow-doubao/doubao_pc/#{version}/Doubao_universal_#{version}.dmg"
  url "https://lf-flow-web-cdn.doubao.com/obj/flow-doubao/doubao_pc/#{version}/Doubao_mac_universal_#{version}-signed.zip"
  name "Doubao"
  desc "AI developed by ByteDance"
  homepage "https://www.doubao.com/"

  livecheck do
    url "https://www.doubao.com/samantha/desktop/get_latest_version?platform=mac&channel_id=1001"
    regex(/"version":"v?(\d+(?:\.\d+)+)"/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  auto_updates true

  app "Doubao.app"

  uninstall quit: "com.bot.pc.doubao"

  zap trash: [
    "~/Library/Application Scripts/com.bot.pc.doubao.FinderSyncExtension",
    "~/Library/Application Support/Doubao",
    "~/Library/Caches/com.bot.pc.doubao",
    "~/Library/Caches/Doubao",
    "~/Library/Containers/com.bot.pc.doubao.FinderSyncExtension",
    "~/Library/HTTPStorages/com.bot.pc.doubao",
    "~/Library/Preferences/com.bot.pc.doubao.plist",
    "~/Library/Saved Application State/com.bot.pc.doubao.savedState",
  ]
end
