cask "fontmin-app" do
  version "0.2.0"
  sha256 :no_check

  url "https://github.com/ecomfe/fontmin-app/releases/download/v#{version}/Fontmin-v#{version}-osx64.zip",
      verified: "github.com/ecomfe/fontmin-app/"
  name "Fontmin"
  desc "First Solution Of Font Subsetting All By JavaScript"
  homepage "https://ecomfe.github.io/fontmin"

  livecheck do
    url "https://github.com/ecomfe/fontmin-app/releases"
    strategy :git
  end

  app "Fontmin.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/Fontmin.app"],
                   sudo:         false,
                   must_succeed: false,
                   print_stderr: false
  end

  zap trash: [
    "~/Library/Application Support/Fontmin",
    "~/Library/Preferences/com.node-webkit-builder.fontmin,plist",
    "~/Library/Saved Application State/com.node-webkit-builder.fontmin.savedState",
  ]
end
