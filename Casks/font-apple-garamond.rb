cask "font-apple-garamond" do
  version :latest
  sha256 :no_check

  url "file:///System/Library/PrivateFrameworks/FontServices.framework/Resources/Fonts/ApplicationSupport/Garamond.ttc"
  name "Apple Garamond"
  homepage "https://developer.apple.com/fonts/"

  font "Garamond.ttc"
end
