cask "sogou-skin-editor" do
  version "1.0.0"

  url "https://pinyin.sogou.com/mac/softdown.php?r=skineditor"
  name "SGSkinEditor"
  name "搜狗输入法皮肤编辑器"
  desc "Skin editor app for sougou input method"
  homepage "https://pinyin.sogou.com/mac/skineditor.php"

  livecheck do
    url "https://pinyin.sogou.com/mac/skineditor.php"
    strategy :page_match
    regex(/<span class="post_type">[^<]+for Mac (\d+(?:\.\d+)+).*/)
  end

  # auto_updates false
  # depends_on macos: ">= :yosemite"

  app "SGSkinEditor.app"

  zap trash: [
    "~/Library/Caches/com.sogou.SGSkinEditor",
    "~/Library/Preferences/com.sogou.SGSkinEditor.plist",
    "~/Library/Saved Application State/com.sogou.SGSkinEditor.savedState",
  ]
end
