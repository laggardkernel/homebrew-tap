cask "fcitx-rime" do
  version "0.3.0"

  url "https://github.com/fcitx-contrib/fcitx5-macos-installer/releases/download/#{version}/Fcitx5-Rime.zip"
  name "Fcitx"
  desc "Fcitx5 input method framework"
  homepage "https://github.com/fcitx-contrib/fcitx5-macos"

  livecheck do
    url "https://github.com/fcitx-contrib/fcitx5-macos-installer"
    strategy :github_latest
  end

  auto_updates true

  installer manual: "Fcitx5Installer.app"

  # /Library/Input Methods/Fcitx5.app/Contents/Resources/uninstall.sh "$USER"
  uninstall quit:   "org.fcitx.inputmethod.Fcitx5",
            delete: "/Library/Input Methods/Fcitx5.app" # delete but not pkgutil

  zap trash: "~/Library/fcitx5",
      rmdir: [
        "~/.config/fcitx5",
        "~/.local/share/fcitx5", # rime
      ]
end
