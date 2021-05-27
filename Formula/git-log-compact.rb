class GitLogCompact < Formula
  desc "Compact alternative to git log --oneline"
  homepage "https://github.com/cxw42/git-log-compact"
  head "https://github.com/cxw42/git-log-compact.git", branch: "fewer-qx"

  bottle :unneeded

  depends_on "perl" if MacOS.version >= :mojave

  def install
    bin.install "git-log-compact"
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
