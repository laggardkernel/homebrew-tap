cask "font-google-eb-garamond" do
  version :latest
  sha256 :no_check

  url "https://github.com/google/fonts.git",
      verified:  "github.com/google/fonts",
      branch:    "main",
      only_path: "ofl/ebgaramond"
  name "EB Garamond from Google Fonts"
  homepage "https://fonts.google.com/specimen/EB+Garamond"
  # homepage "https://googlefonts.github.io/ebgaramond-specimen/"


  font "EBGaramond-Italic[wght].ttf"
  font "EBGaramond[wght].ttf"

  # No zap stanza required
end
