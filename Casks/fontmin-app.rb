cask "fontmin-app" do
  version "0.2.0"

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

  zap trash: [
    "~/Library/Application Support/Fontmin",
    "~/Library/Preferences/com.node-webkit-builder.fontmin,plist",
    "~/Library/Saved Application State/com.node-webkit-builder.fontmin.savedState",
  ]
end
