cask "sogou-input" do
  version "618b"

  # sha256

  url "https://rabbit-linker.vercel.app/gtimg/sogou_mac/#{version}",
      verified: "rabbit-linker.vercel.app/"
  name "Sogou Input Method"
  name "搜狗输入法"
  desc "Input method supporting full and double spelling"
  homepage "https://pinyin.sogou.com/mac/"

  livecheck do
    url :homepage
    # https://ime-sec.gtimg.com/{dt}/{foo}/pc/dl/gzindex/{ts}/sogou_mac_617a.zip
    regex(%r{href="https://ime-sec.gtimg.com/[^"]+/sogou_mac_(\d+(?:\.\d+)*[a-z]*)\.zip}i)
    strategy :page_match do |page|
      page.scan(regex).map { |match| match&.first }
    end
  end

  auto_updates true

  installer manual: "sogou_mac_#{version}.app"

  uninstall launchctl: "com.sogou.SogouServices",
            delete:    [
              "/Library/Input Methods/SogouInput.app",
              "/Library/QuickLook/SogouSkinFileQuickLook.qlgenerator",
            ]

  zap trash: [
        "~/.sogouinput",
        "~/Library/Application Support/Sogou/EmojiPanel",
        "~/Library/Application Support/Sogou/InputMethod",
        "~/Library/Caches/com.sogou.inputmethod.sogou",
        "~/Library/Caches/com.sogou.SGAssistPanel",
        "~/Library/Caches/com.sogou.SogouPreference",
        "~/Library/Caches/SogouServices",
        "~/Library/Cookies/com.sogou.inputmethod.sogou.binarycookies",
        "~/Library/Cookies/com.sogou.SogouPreference.binarycookies",
        "~/Library/Cookies/SogouServices.binarycookies",
        "~/Library/Preferences/com.sogou.SogouPreference.plist",
        "~/Library/Saved Application State/com.sogou.SogouInstaller.savedState",
      ],
      rmdir: "~/Library/Application Support/Sogou"
end
# https://github.com/Homebrew/homebrew-cask/pull/155138
