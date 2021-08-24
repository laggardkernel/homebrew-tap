class Gfwlist2dnsmasq < Formula
  desc "Shell script which convert gfwlist into dnsmasq rules."
  homepage "https://github.com/cokebar/gfwlist2dnsmasq"
  version "202e52f"
  url "https://github.com/cokebar/gfwlist2dnsmasq/archive/#{version}.tar.gz"
  # sha256 ""
  head "https://github.com/cokebar/gfwlist2dnsmasq.git"
  license "GPL-3.0"
  version_scheme 1

  livecheck do
    url "https://github.com/cokebar/gfwlist2dnsmasq/commits/master/gfwlist2dnsmasq.sh"
    regex(%r{href="/cokebar/gfwlist2dnsmasq/tree/([a-z0-9]{7,}+)" })
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
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
