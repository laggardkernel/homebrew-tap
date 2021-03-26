class NaliBin < Formula
  desc "An offline tool for querying IP geographic information and CDN provider."
  homepage "https://github.com/zu1k/nali"
  version "0.2.3"
  url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-darwin-amd64-v#{version}.gz"
  sha256 "fb6ef5c19b4b71ab00504e374f868e93a05578d61b769333d20e3e7567038327"

  livecheck do
    url "https://github.com/zu1k/nali/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  bottle :unneeded

  # conflicts_with "nali", :because => "same package"

  def install
    bin.install Dir["nali-darwin-*"][0] => "nali"
  end

  def caveats; <<~EOS
    zu1k/nali has support for different geoip databases. Related
    environment varialbles are:

    - NALI_DB
    - NALI_DB_HOME

    Check the project's README for detail. https://github.com/zu1k/nali
  EOS
  end

  test do
    system "#{bin}/nali", "-h"
  end
end
