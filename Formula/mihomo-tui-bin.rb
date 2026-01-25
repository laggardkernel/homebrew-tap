class MihomoTuiBin < Formula
  desc "Simple TUI dashboard for monitoring and managing Mihomo via its REST API"
  homepage "https://github.com/potoo0/mihomo-tui"
  version "0.3.0"
  license "MIT"
  revision 0

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  os_name = OS.mac? ? "macOS" : "Linux-gnu"
  if OS.mac?
    cpu_arch = "arm64"
  else
    cpu_arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
  end
  basename = "mihomo-tui-#{os_name}-#{cpu_arch}.tar.gz"
  url "https://github.com/potoo0/mihomo-tui/releases/download/v#{version}/#{basename}"

  def install
    bin.install "mihomo-tui"
  end
end
