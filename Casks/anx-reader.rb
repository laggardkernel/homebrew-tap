cask "anx-reader" do
  version "1.10.1"

  url "https://github.com/Anxcye/anx-reader/releases/download/v#{version}/Anx-Reader-macos-#{version}.zip"
  name "Anx Reader"
  desc "Modern e-book reader with powerful AI and multi-format support"
  homepage "https://anx.anxcye.com/"

  livecheck do
    url "https://github.com/Anxcye/anx-reader/releases"
    regex(%r{href=".*?/releases/tag/v?(\d+(?:\.\d+)+)"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  auto_updates false
  conflicts_with cask: "anx-reader@beta"
  # depends_on macos: ">= :monterey"

  app "Anx Reader.app"

  uninstall quit: "com.anxcye.anxReader"

  zap trash: [
    "~/Library/Application Support/com.anxcye.anxReader",
    "~/Library/Caches/com.anxcye.anxReader",
    "~/Library/Preferences/com.anxcye.anxReader.plist",
  ]
end
