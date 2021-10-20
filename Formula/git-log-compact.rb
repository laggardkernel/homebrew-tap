class GitLogCompact < Formula
  desc "Compact alternative to git log --oneline"
  homepage "https://github.com/cxw42/git-log-compact"
  version "72e8207"
  url "https://github.com/cxw42/git-log-compact/archive/#{version}.tar.gz"
  # sha256 ""
  head "https://github.com/cxw42/git-log-compact.git", branch: "fewer-qx"
  license "GPL-2.0"

  livecheck do
    url "https://github.com/cxw42/git-log-compact/commits/fewer-qx/git-log-compact"
    regex(%r{href="/cxw42/git-log-compact/tree/([a-z0-9]{7,}+)" })
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  # depends_on "perl" if MacOS.version >= :mojave

  def install
    bin.install "git-log-compact"
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      git-log-compact: A compact alternative to `git log --oneline` that includes
      dates, times and author and/or committer initials
      in a space efficient output format.

      Recommended configurations:
        git config --global alias.lc log-compact
        git config --global log-compact.defaults "--two-initials --abbrev=8"

      PS: This formula uses the fork cxw42/git-log-compact but not the original one
      for more options.
    EOS
  end

  test do
    system "#{bin}/git-log-compact", "-h"
  end
end
