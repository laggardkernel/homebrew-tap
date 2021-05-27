cask "font-um-typewriter" do
  version "001.002"
  sha256 "17bb1b2fbb793ee37485118ac3b11f33b759b7e612ed0b27db24e4a79e9d75dc"

  url "http://mirrors.ctan.org/fonts/umtypewriter.zip"
  name "UM Typewriter"
  homepage "https://ctan.org/tex-archive/fonts/umtypewriter"

  livecheck do
    url "https://ctan.org/tex-archive/fonts/umtypewriter"
    regex(/Version.+?(\d+(?:\.\d+)+)/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  font "umtypewriter/UMTypewriter-Bold.otf"
  font "umtypewriter/UMTypewriter-BoldItalic.otf"
  font "umtypewriter/UMTypewriter-Italic.otf"
  font "umtypewriter/UMTypewriter-Oblique.otf"
  font "umtypewriter/UMTypewriter-Regular.otf"
end
