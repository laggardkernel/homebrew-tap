cask "raycast-versioned" do
  if MacOS.version <= :mojave
    version "1.26.3"
    url "https://pseudocold.com/app/raycast/#{version}/Raycast_v#{version}_x86.dmg"
    livecheck do
      skip "1.26.3, last version compatible with Mojave"
    end
  else
    version "latest"
    sha256 :no_check
    url "https://api.raycast.app/v2/download"
    livecheck do
      skip "Only link to the latest release is provided"
    end
    # livecheck do
    #   url :url
    #   strategy :header_match
    #   regex(/Raycast[._-]v?(\d+(?:\.\d+)+)[._-]universal\.dmg/i)
    # end
  end

  name "Raycast"
  desc "Control your tools with a few keystrokes"
  homepage "https://raycast.app/"

  auto_updates true
  depends_on macos: ">= :mojave"

  app "Raycast.app"

  uninstall quit: "com.raycast.macos"

  zap trash: [
    "~/Library/Application Support/com.raycast.macos",
    "~/Library/Caches/com.raycast.macos",
    "~/Library/Cookies/com.raycast.macos.binarycookies",
    "~/Library/Preferences/com.raycast.macos.plist",
  ]
end
