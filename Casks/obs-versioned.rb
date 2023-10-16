cask "obs-versioned" do
  arch arm: "arm64", intel: "x86_64"

  on_mojave :or_older do
    # Qt6 since 28 dropped support for macOS 10.13 & 10.14
    # url "https://github.com/obsproject/obs-studio/releases/download/#{version}/obs-mac-#{version}.dmg"
    version "27.2.4"
    url "https://cdn-fastly.obsproject.com/downloads/obs-mac-#{version}.dmg"
  end
  on_catalina :or_newer do
    # https://github.com/obsproject/obs-studio/issues/8849
    version "29.0.2"
    url "https://cdn-fastly.obsproject.com/downloads/obs-studio-#{version}-macos-#{arch}.dmg"
  end

  name "OBS"
  desc "Open-source software for live streaming and screen recording"
  homepage "https://obsproject.com/"

  livecheck do
    skip "Legacy version"
  end

  auto_updates true
  conflicts_with cask: ["homebrew/cask-versions/obs-beta", "obs"]
  depends_on macos: ">= :high_sierra"

  app "OBS.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/obs.wrapper.sh"
  binary shimscript, target: "obs"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/bash
      exec '#{appdir}/OBS.app/Contents/MacOS/OBS' "$@"
    EOS
  end

  uninstall delete: "/Library/CoreMediaIO/Plug-Ins/DAL/obs-mac-virtualcam.plugin"

  zap trash: [
    "~/Library/Application Support/obs-studio",
    "~/Library/HTTPStorages/com.obsproject.obs-studio",
    "~/Library/Preferences/com.obsproject.obs-studio.plist",
    "~/Library/Saved Application State/com.obsproject.obs-studio.savedState",
  ]
end
