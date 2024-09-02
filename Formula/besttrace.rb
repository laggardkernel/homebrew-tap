class Besttrace < Formula
  desc "Enhanced traceroute with IP display, developed by IPIP.NET"
  homepage "https://www.ipip.net/product/client.html#besttrace"
  url "https://cdn.ipip.net/17mon/besttrace4linux.zip"
  version "1.3.4"
  license :cannot_represent

  livecheck do
    # Version provided in homepage doesn't match version of the pkg.
    url "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=besttrace"
    regex(/pkgver=v?(\d+(?:\.\d+)+(?:[-_].+?)?)/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq
    end
  end

  def install
    bin.install Dir.glob("besttrace*mac")[0] => "besttrace"
    prefix.install Dir.glob("*.txt")[0] => "CHANGELOG.txt"
  end

  test do
    system bin/"besttrace", "--version"
  end
end
