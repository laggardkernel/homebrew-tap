cask "filezilla" do
  version "3.55.0"
  # sha256 ""

  url "https://download.filezilla-project.org/client/FileZilla_#{version}_macosx-x86.app.tar.bz2"
  appcast "https://filezilla-project.org/versions.php?type=client"
  name "FileZilla"
  homepage "https://filezilla-project.org/"

  livecheck do
    url "https://download.filezilla-project.org/client/"
    regex(/href=['"]?FileZilla[._-]v?(\d+(?:\.\d+)+)[._-]macosx?[._-].+?['"]?/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq
    end
  end

  app "FileZilla.app"

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/de.filezilla.sfl*",
    "~/Library/Saved Application State/de.filezilla.savedState",
    "~/Library/Preferences/de.filezilla.plist",
    # '~/.config/filezilla',
  ]

  def caveats
    <<~EOS
      Sites and settings stored in '~/.config/filezilla' will not be removed even with
      'brew uninstall --zap'. The decision of whether to remove it is left for users.
    EOS
  end
end
# Reason why it's be deleted from homebrew-cask
# https://github.com/Homebrew/homebrew-cask/pull/55583#issuecomment-443929273
# https://github.com/Homebrew/homebrew-cask/commit/3a68bc709920a28d81e84afd764e5ac74f146830
