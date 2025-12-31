class QBin < Formula
  desc "Tiny command-line DNS client with support for UDP, TCP, DoT, DoH, DoQ and ODoH"
  homepage "https://github.com/natesales/q"
  version "0.19.11"
  license "GPL-3.0-only"

  os_name = OS.mac? ? "darwin" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "amd64"
  basename = ["q", version, os_name, cpu_arch].join("_")
  url "https://github.com/natesales/q/releases/download/v#{version}/#{basename}.tar.gz"

  def install
    bin.install "q"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/q --version")
    assert_match "ns: ns1.dnsimple.com.", shell_output("#{bin}/q brew.sh NS --format yaml")
  end
end
