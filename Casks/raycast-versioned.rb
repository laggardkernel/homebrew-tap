cask "raycast-versioned" do
  on_mojave :or_older do
    version "1.26.3"
    url "https://pseudocold.com/app/raycast/#{version}/Raycast_v#{version}_x86.dmg"
    livecheck do
      skip "1.26.3, last version compatible with Mojave"
    end
  end
  on_catalina :or_older do
    version "1.44.0"
    url "https://releases.raycast.com/releases/#{version}/download?build=universal"
    livecheck do
      skip "Legacy version"
    end
  end

  name "Raycast"
  desc "Control your tools with a few keystrokes"
  homepage "https://raycast.com/"

  auto_updates true
  depends_on macos: ">= :mojave"

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
