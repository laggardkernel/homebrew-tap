cask "keytty" do
  version "1.2.8"
  # sha256 ""

  url "https://github.com/keytty/shelter/releases/download/#{version}/Keytty.#{version}.dmg",
      verified: "github.com/keytty/shelter/"
  name "Keytty"
  desc "Control your mouse with the keyboard"
  homepage "https://keytty.com/"

  livecheck do
    url "https://github.com/keytty/shelter/releases/"
    strategy :github_release
  end

  app "Keytty.app"

  zap trash: [
    "~/Library/Preferences/com.keytty.keytty.plist",
  ]
end
