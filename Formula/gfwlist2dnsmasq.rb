
class VersionFetcher
  def initialize
    @url = "https://raw.githubusercontent.com/cokebar/gfwlist2dnsmasq/master/gfwlist2dnsmasq.sh"
  end

  def version
    require "open-uri"
    require "net/http"
    require "json"

    html = URI(@url).open.read
    regex = /version:\s*v?(\d+(?:\.\d+)+[a-z]?).*/i

    m = html.match(regex)
    if m
      m[1]
    else
      "latest"
    end
  end
end

class Gfwlist2dnsmasq < Formula
  desc "Shell script which convert gfwlist into dnsmasq rules."
  homepage "https://github.com/cokebar/gfwlist2dnsmasq"
  url "https://github.com/cokebar/gfwlist2dnsmasq/archive/master.tar.gz"
  version VersionFetcher.new.version.to_s
  # sha256
  head "https://github.com/cokebar/gfwlist2dnsmasq.git"
  license "GPL-3.0"

  livecheck do
    skip "Version unknown before installation"
  end

  bottle :unneeded

  def install
    bin.install "gfwlist2dnsmasq.sh" => "gfwlist2dnsmasq"
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      This script needs sed, base64, curl(orwget). You should have
      these binaries on you system.
    EOS
  end

  test do
    system "#{bin}/gfwlist2dnsmasq", "--help"
  end
end
