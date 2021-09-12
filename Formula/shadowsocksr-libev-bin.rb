class ShadowsocksrLibevBin < Formula
  desc "Static binaries of shadowsocksr-libev"
  homepage "https://github.com/tindy2013/shadowsocks-static-binaries"
  version "54d95d8"
  url "https://github.com/tindy2013/shadowsocks-static-binaries/raw/#{version}/shadowsocksr-libev/macos/ssr-local"
  # url "https://raw.githubusercontent.com/tindy2013/shadowsocks-static-binaries/#{version}/shadowsocksr-libev/macos/ssr-local"
  license :cannot_represent

  livecheck do
    url "https://github.com/tindy2013/shadowsocks-static-binaries/commits/master/shadowsocksr-libev/macos/ssr-local"
    regex(%r{href="/tindy2013/shadowsocks-static-binaries/tree/([a-z0-9]{7,}+)" }i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  bottle :unneeded

  def install
    bin.install "ssr-local"
    prefix.install_metafiles
  end

  test do
    system "#{bin}/ssr-local", "--help"
  end
end
# https://surgio.js.org/guide/install-ssr-local.html
