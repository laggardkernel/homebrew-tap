cask 'language-switcher' do
  version '1.1.7'
  sha256 'c65882f00b195a0821dd3baf2c81a71d3ddd01b64cf6beaf56abb47cb948ffa8'

  # Website unmaintained, get the app from the web
  url "https://pseudocold.com/app/language-switcher/language-switcher-#{verison}.dmg"
  # url "https://feng-bbs-att-1255531212.file.myqcloud.com/2013/03/13/4671851_Language_Switcher_1_1_7.dmg"
  # url "http://www.tj-hd.co.uk/downloads/Language_Switcher_#{version.dots_to_underscores}.dmg"
  appcast 'http://feeds.tj-hd.co.uk/feeds/language_switcher/appcast.xml'
  name 'Language Switcher'
  homepage 'http://www.tj-hd.co.uk/en-gb/languageswitcher/'

  depends_on macos: "< :catalina"

  livecheck do
    skip "App unmaintained"
  end

  app 'Language Switcher.app'

  zap trash: [
    "~/Library/Preferences/com.TJ-HD.Language_Switcher.plist",
    "~/Library/Saved Application State/com.TJ-HD.Language_Switcher.savedState",
  ]

  def caveats
    <<~EOS
      'Language Switcher.app' serves as a frontend of the 'AppleLanguages' key of
      'defaults write'. E.g.

        defaults write com.apple.TextEdit AppleLanguages '("zh-Hans-CN")'

      The bundle id could be get with command like this,

        mdls -name kMDItemCFBundleIdentifier /Applications/Mail.app

      While, macOS has this app specific language setting feature built-in since
      macOS 10.15 Catalina, which means this cask/app is not needed anymore.

      References

      - https://apple.stackexchange.com/questions/245

    EOS
  end

end
# https://github.com/Homebrew/homebrew-cask/pull/70945
# https://www.feng.com/post/6196977
