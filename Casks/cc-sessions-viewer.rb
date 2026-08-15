cask "cc-sessions-viewer" do
  version "0.3.18"
  sha256 :no_check

  url "https://github.com/jerrywu001/cc-sessions-viewer/releases/download/v#{version}/Sessions.Viewer_#{version}_universal.dmg"
  name "Sessions Viewer"
  desc "Desktop viewer for Claude Code, Codex, Antigravity CLI and OpenCode sessions"
  homepage "https://github.com/jerrywu001/cc-sessions-viewer"

  livecheck do
    url "https://github.com/jerrywu001/cc-sessions-viewer/releases"
    strategy :github_releases
  end

  auto_updates false
  depends_on :macos

  app "Sessions Viewer.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/Sessions Viewer.app"],
                   sudo:         false,
                   must_succeed: false,
                   print_stderr: false
  end

  uninstall quit: "com.wuchao.cc-sessions-viewer"

  zap trash: [
    "~/Library/Application Support/com.wuchao.cc-sessions-viewer",
    "~/Library/Caches/com.wuchao.cc-sessions-viewer",
    "~/Library/Preferences/com.wuchao.cc-sessions-viewer.plist",
    "~/Library/Saved Application State/com.wuchao.cc-sessions-viewer.savedState",
  ]
end
