cask "cloud-uploader" do
  version "1.3.3"

  url "https://github.com/lulu-ls/cloud-uploader/releases/download/#{version}/cloud-uploader-#{version}.dmg"
  name "CloudUploader"
  desc "网易云音乐 Mac 云盘上传工具"
  homepage "https://github.com/lulu-ls/cloud-uploader"

  livecheck do
    url "https://github.com/lulu-ls/cloud-uploader/releases"
    strategy :github_release
  end

  auto_updates false

  app "cloud-uploader.app"

  zap trash: [
    "~/Library/Application Support/cloud-uploader",
    "~/Library/Preferences/com.net-easy-cloud-music-uploader.app.plist",
    "~/Library/Saved Application State/com.net-easy-cloud-music-uploader.savedState",
  ]
end
