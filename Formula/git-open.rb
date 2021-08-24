class GitOpen < Formula
  desc "Open the repository homepage from command-line"
  homepage "https://github.com/paulirish/git-open"
  version "c908a50"
  url "https://github.com/paulirish/git-open/archive/#{version}.tar.gz"
  # sha256 ""
  head "https://github.com/paulirish/git-open.git"
  license "MIT"
  version_scheme 1

  livecheck do
    url "https://github.com/paulirish/git-open/commits/master/git-open"
    regex(%r{href="/paulirish/git-open/tree/([a-z0-9]{7,}+)" })
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  bottle :unneeded

  # depends_on "bash" if MacOS.version >= :mojave

  def install
    bin.install "git-open"
    prefix.install_metafiles
  end

  test do
    system "#{bin}/git-open", "-h"
  end
end
