cask "cloud-uploader" do
  version "1.3.5"
  sha256 :no_check

  url "https://github.com/lulu-ls/cloud-uploader/releases/download/#{version}/cloud-uploader-#{version}.dmg"
  name "CloudUploader"
  desc "网易云音乐云盘上传工具"
  homepage "https://github.com/lulu-ls/cloud-uploader"

  livecheck do
    url "https://github.com/lulu-ls/cloud-uploader/releases"
    strategy :github_releases
  end

  auto_updates false

  app "cloud-uploader.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/cloud-uploader.app"],
                   sudo:         false,
                   must_succeed: false,
                   print_stderr: false
  end

  zap trash: [
    "~/Library/Application Support/cloud-uploader",
    "~/Library/Preferences/com.net-easy-cloud-music-uploader.app.plist",
    "~/Library/Saved Application State/com.net-easy-cloud-music-uploader.savedState",
  ]
end
