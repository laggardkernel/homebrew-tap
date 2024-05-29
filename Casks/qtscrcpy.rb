cask "qtscrcpy" do
  version "2.2.1"
  url "https://github.com/barry-ran/QtScrcpy/releases/download/v#{version}/QtScrcpy-mac-x64-v#{version}.dmg",
      verified: "github.com/barry-ran/QtScrcpy/"
  name "QtScrcpy"
  desc "Android real-time display control software"
  homepage "https://github.com/barry-ran/QtScrcpy"

  auto_updates false

  app "QtScrcpy.app"

  uninstall quit: "com.west2online.ClashXPro"

  zap trash: [
    "~/Library/Saved Application State/rankun.QtScrcpy.savedState",
  ]
end
