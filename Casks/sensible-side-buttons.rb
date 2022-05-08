cask "sensible-side-buttons" do
  version "1.08.2"
  # sha256 ""

  # Desousak's fork fixes compatibile problem with Chrome
  # https://github.com/archagon/sensible-side-buttons/issues/58
  url "https://github.com/Desousak/sensible-side-buttons/releases/download/#{version}/SensibleSideButtons.app.zip",
      verified: "github.com/Desousak/sensible-side-buttons/"
  name "Sensible Side Buttons"
  homepage "https://sensible-side-buttons.archagon.net/"

  conflicts_with cask: "sensiblesidebuttons"

  app "SensibleSideButtons.app"

  zap trash: [
    "~/Library/Preferences/net.archagon.sensible-side-buttons.plist",
    "~/Library/Preferences/net.archagon.sensible-side-buttons.plist.*",
  ]
end
