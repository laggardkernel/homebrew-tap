cask "qtscrcpy" do
  version "3.0.1"

  url "https://github.com/barry-ran/QtScrcpy/releases/download/v#{version}/QtScrcpy-mac-x64-v#{version}.dmg",
      verified: "github.com/barry-ran/QtScrcpy/"
  name "QtScrcpy"
  desc "Android real-time display control software"
  homepage "https://github.com/barry-ran/QtScrcpy"

  auto_updates false
  depends_on arch: :intel

  app "QtScrcpy.app"

  uninstall quit: "rankun.QtScrcpy.savedState"

  zap trash: "~/Library/Saved Application State/rankun.QtScrcpy.savedState"
end
