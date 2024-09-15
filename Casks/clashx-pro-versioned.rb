cask "clashx-pro-versioned" do
  on_mojave :or_older do
    # last build with clash core < 2023.02.16
    version "1.96.2.1"
  end

  url "https://appcenter.clashx.workers.dev/api/1cd052f7-e118-4d13-87fb-35176f9702c1/#{version}",
      verified: "appcenter.clashx.workers.dev/api/1cd052f7-e118-4d13-87fb-35176f9702c1/"
  name "ClashX Pro"
  desc "Rule-based custom proxy with GUI based on clash"
  homepage "https://github.com/yichengchen/clashX"

  livecheck do
    skip "Legacy version"
  end

  auto_updates true
  conflicts_with cask: "clashx-pro"
  depends_on macos: ">= :mojave"

  app "ClashX Pro.app"

  uninstall launchctl: "com.west2online.ClashXPro.ProxyConfigHelper",
            quit:      "com.west2online.ClashXPro",
            delete:    [
              "/Library/LaunchDaemons/com.west2online.ClashXPro.ProxyConfigHelper.plist",
              "/Library/PrivilegedHelperTools/com.west2online.ClashXPro.ProxyConfigHelper",
            ]

  zap trash: [
    "~/Library/Application Support/com.west2online.ClashXPro",
    "~/Library/Caches/com.west2online.ClashXPro",
    "~/Library/Logs/ClashX Pro",
    "~/Library/Preferences/com.west2online.ClashXPro.plist",
  ]
end
