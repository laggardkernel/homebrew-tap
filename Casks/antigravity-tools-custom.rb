cask "antigravity-tools-custom" do
  arch arm: "aarch64", intel: "x86"

  version "3.3.45"

  url "https://github.com/lbjlaq/Antigravity-Manager/releases/download/v#{version}/Antigravity.Tools_#{version}_#{arch}.dmg"
  name "Antigravity Tools"
  desc "Professional Antigravity Account Manager & Switcher. One-click seamless account switching"
  homepage "https://github.com/lbjlaq/Antigravity-Manager"

  auto_updates true

  app "Antigravity Tools.app"

  zap trash: [
    "~/.antigravity_tools",
    "~/Library/Caches/com.lbjlaq.antigravity-tools",
    "~/Library/WebKit/com.lbjlaq.antigravity-tools",
  ]
end
