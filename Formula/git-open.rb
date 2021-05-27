class GitOpen < Formula
  desc "Open the repository homepage from command-line"
  homepage "https://github.com/paulirish/git-open"
  url "https://github.com/paulirish/git-open/archive/v2.1.0.tar.gz"
  sha256 "0cf7f7f55c611c8dfccf0a3135df4032f2ea085491be84fb565cac2d744c4951"
  head "https://github.com/paulirish/git-open.git"

  bottle :unneeded

  depends_on "bash" if MacOS.version >= :mojave

  def install
    bin.install "git-open"
  end

  test do
    system "#{bin}/git-open", "-h"
  end
end
