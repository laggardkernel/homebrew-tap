cask "raycast-versioned" do
  if MacOS.version <= '10.14'
    version "1.26.3"
    url "https://pseudocold.com/app/raycast/#{version}/Raycast_v#{version}_x86.dmg"
  else  # MacOS.version >= '10.15'
    version "1.44.0"
    url "https://releases.raycast.com/releases/#{version}/download?build=universal"
  end

  name "Raycast"
  desc "Control your tools with a few keystrokes"
  homepage "https://raycast.com/"

  livecheck do
    skip "Legacy version"
  end

  auto_updates true

  app "Raycast.app"

  uninstall quit: "com.raycast.macos"

  zap trash: [
    "~/.config/raycast",
    "~/Library/Application Support/com.raycast.macos",
    "~/Library/Caches/com.raycast.macos",
    "~/Library/Caches/SentryCrash/Raycast",
    "~/Library/Cookies/com.raycast.macos.binarycookies",
    "~/Library/HTTPStorages/com.raycast.macos",
    "~/Library/Preferences/com.raycast.macos.plist",
  ]
end
