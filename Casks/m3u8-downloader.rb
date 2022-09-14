cask "m3u8-downloader" do
  arch = Hardware::CPU.intel? ? "x64" : "arm64"

  version "2.0.7"

  url "https://github.com/HeiSir2014/M3U8-Downloader/releases/download/v#{version}/M3U8-Downloader-mac_#{arch}-#{version}.dmg"
  name "M3U8-Downloader"
  desc "M3U8-Downloader 支持多线程、断点续传、加密视频下载缓存"
  homepage "https://github.com/HeiSir2014/M3U8-Downloader"

  livecheck do
    url "https://github.com/HeiSir2014/M3U8-Downloader/releases"
    strategy :github_release
  end

  auto_updates false

  app "M3U8-Downloader.app"

  zap trash: [
    "~/Library/Application Support/M3U8-Downloader",
    "~/Library/Preferences/cn.heisir.m3u8-downloader-mac.plist",
    "~/Library/Saved Application State/cn.heisir.m3u8-downloader-mac.savedState",
  ]
end
