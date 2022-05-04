cask "pictureview" do
  version "2.2.3"
  # sha256 ""

  url "https://wl879.github.io/apps/picview/PictureView_#{version}.dmg"
  name "PictureView"
  homepage "https://wl879.github.io/apps/picview/"

  livecheck do
    url "https://wl879.github.io/apps/picview/note.html"
    regex(%r{<h3>v?(\d+(?:\.\d+)+)\s?.+</h3>}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
  end

  depends_on macos: ">= :catalina"

  app "PictureView.app"

  zap trash: [
    "~/Library/Preferences/com.zouke.PictureView.plist",
  ]
end
