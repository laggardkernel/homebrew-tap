cask "clash-verge" do
  arch = Hardware::CPU.intel? ? "x64" : "aarch64"

  version "1.2.3"
  # sha256

  url "https://github.com/zzzgydi/clash-verge/releases/download/v#{version}/Clash.Verge_#{version}_#{arch}.dmg"
  name "Clash Verge"
  desc "Clash GUI based on tauri. Supports Windows, macOS and Linux"
  homepage "https://github.com/zzzgydi/clash-verge"

  livecheck do
    url "https://github.com/zzzgydi/clash-verge/releases"
    regex(%r{href=".*?/releases/tag/v?(\d+(?:\.\d+)+)"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  auto_updates false
  # depends_on macos: ">= :sierra"  # not sure

  app "Clash Verge.app"

  zap trash: [
    # "~/Library/Application Support/top.gydi.clashverge",
    "~/Library/Caches/top.gydi.clashverge",
    # "~/Library/Logs/Clash Verge",
    "~/Library/Preferences/top.gydi.clashverge.plist",
    "~/Library/Saved Application State/top.gydi.clashverge",
  ]

  def caveats
    <<~EOS
      There's no automatic TUN setup and teardown for macOS yet.
      https://github.com/zzzgydi/clash-verge/issues/82
      For a more mature macOS GUI experience, try ClashX Meta instead.
    EOS
  end
end
