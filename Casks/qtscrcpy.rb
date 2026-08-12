cask "qtscrcpy" do
  version "4.1.1"

  on_arm do
    url "https://github.com/barry-ran/QtScrcpy/releases/download/v#{version}/QtScrcpy-mac-arm64-Qt6.5.3-v#{version}.dmg"
  end
  on_intel do
    url "https://github.com/barry-ran/QtScrcpy/releases/download/v#{version}/QtScrcpy-mac-x64-Qt5.15.2-v#{version}.dmg"
  end

  sha256 :no_check

  name "QtScrcpy"
  desc "Android real-time display control software"
  homepage "https://github.com/barry-ran/QtScrcpy"

  auto_updates false

  app "QtScrcpy.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/QtScrcpy.app"],
                   sudo:         false,
                   must_succeed: false,
                   print_stderr: false
  end

  uninstall quit: "rankun.QtScrcpy"

  zap trash: "~/Library/Saved Application State/rankun.QtScrcpy.savedState"
end
