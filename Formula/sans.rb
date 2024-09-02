class Sans < Formula
  desc "Simple anti-spoofing DNS server"
  homepage "https://github.com/puxxustc/sans"
  # HEAD only, no regular release
  license "GPL-3.0"
  head "https://github.com/puxxustc/sans.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-if"
    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{HOMEBREW_PREFIX}/etc", "--mandir=#{man}"
    system "make"
    system "make", "install"
  end

  # TODO: plist

  test do
    system bin/"sans", "--help"
  end
end
# https://github.com/puxxustc/sans/blob/master/contrib/homebrew/sans.rb
