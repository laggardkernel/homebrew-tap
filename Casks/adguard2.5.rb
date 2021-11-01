cask "adguard2.5" do
  version "2.5.3.955"
  sha256 "449a8ca91c8755eef4f5f3f247dfdfcdbf8c2a1096ad01f20d983d1ddafb38bc"

  url "https://static.adguard.com/mac/release/AdGuard-#{version}.dmg"
  name "Adguard"
  desc "Stand alone ad blocker"
  homepage "https://adguard.com/"

  livecheck do
    skip "Versioned app, no longer maintained"
  end

  auto_updates true

  pkg "AdGuard.pkg"

  uninstall pkgutil:   "com.adguard.mac.adguard-pkg",
            launchctl: [
              "com.adguard.mac.adguard.pac",
              "com.adguard.mac.adguard.tun-helper",
            ]

  zap trash: [
    "/Library/com.adguard.mac.adguard.pac",
    "/Library/Application Support/com.adguard.Adguard",
    "~/Library/Application Support/Adguard",
    "~/Library/Application Support/com.adguard.Adguard",
    "~/Library/Application Support/com.adguard.mac.adguard.pac",
    "~/Library/Application Support/com.adguard.mac.adguard.tun-helper",
    "~/Library/Caches/com.adguard.Adguard",
    "~/Library/Cookies/com.adguard.Adguard.binarycookies",
    "~/Library/Logs/Adguard",
    "~/Library/Preferences/com.adguard.Adguard.plist",
  ]

  def caveats
    <<~EOS
      Websocket keeps reconnecting after upgrading to AdGuard 2.6. The problem occurs
      even without any filter rule applied. Rollback to 2.5 until the bug is fixed.
    EOS
  end
end
