class CurlDoh < Formula
  desc "Stand-alone application for DoH (DNS-over-HTTPS) name resolves and lookups"
  homepage "https://github.com/curl/doh"
  head "https://github.com/curl/doh.git"
  # -t is not merged
  # url "https://github.com/curl/doh/archive/doh-0.1.tar.gz"
  # sha256 "b36c4b4a27fabb508d5d3bb0fb58bd9cfadcef30d22e552bbe5c4442ae81e742"

  depends_on "curl-openssl"

  def install
    system "make"
    bin.install "doh"
    man1.install "doh.1"
  end

  test do
    system "#{bin}/doh", "-h"
  end

end
