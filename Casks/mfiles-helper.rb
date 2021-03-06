cask "mfiles-helper" do
  version "2.2.0,20210408"
  sha256 "a09d7b7974bdf1d6f42476269a5a21157af1f3c7c23683d31405e78cb9ac8efd"

  # version_scheme 1 # not needed in Cask

  url "http://mfiles.maokebing.com/mfiles-helper-#{version.before_comma}-macos-#{version.after_comma}.dmg"
  name "MFiles Helper"
  desc "Sharing files easily within local network"
  homepage "http://mfiles.maokebing.com/"

  livecheck do
    url "http://mfiles.maokebing.com/"
    regex(/href=['"]?mfiles[._-]helper[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-](\d+)\.dmg/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match&.first + "," + match&.second
      end
    end
  end

  auto_updates false
  depends_on macos: ">= :yosemite"

  app "MFiles Helper.app"

  zap trash: [
    "/Users/wyh/Library/Preferences/com.windtune.itransfer.plist",
  ]
end
