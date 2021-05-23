cask 'filezilla' do
  version '3.46.3'
  sha256 '4fc40ff94a61ff0cefdb459e0637fafa1fadcf6cc51bf135841c79131e0b6391'

  url "https://download.filezilla-project.org/client/FileZilla_#{version}_macosx-x86.app.tar.bz2"
  appcast 'https://filezilla-project.org/versions.php?type=client'
  name 'FileZilla'
  homepage 'https://filezilla-project.org/'

  livecheck do
    url "https://download.filezilla-project.org/client/"
    regex(/href=['"]?FileZilla[._-]v?(\d+(?:\.\d+)+)[._-]macosx?[._-].+?['"]?/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq
    end
  end

  app 'FileZilla.app'

  zap trash: [
    '~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/de.filezilla.sfl*',
    '~/Library/Saved Application State/de.filezilla.savedState',
    '~/Library/Preferences/de.filezilla.plist',
    '~/.config/filezilla',
  ]
end
