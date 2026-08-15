cask "sigil1" do
  version "1.9.30"
  sha256 "d43f109c9c5972ab808c9bf734ff873f477e7c571c4141f5bd217041f65f2c07"

  url "https://github.com/Sigil-Ebook/Sigil/releases/download/#{version}/Sigil.app-#{version}-Mac.txz",
      verified: "github.com/Sigil-Ebook/Sigil/"
  name "Sigil"
  desc "EPUB ebook editor"
  homepage "https://sigil-ebook.com/"

  livecheck do
    skip "Legacy version"
  end

  # depends_on macos: ">= :sierra"

  app "Sigil.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/Sigil.app"],
                   sudo:         false,
                   must_succeed: false,
                   print_stderr: false
  end

  zap trash: [
    "~/Library/Application Support/sigil-ebook",
    "~/Library/Preferences/com.sigil-ebook.Sigil.app.plist",
    "~/Library/Saved Application State/com.sigil-ebook.Sigil.app.savedState",
  ]
end
