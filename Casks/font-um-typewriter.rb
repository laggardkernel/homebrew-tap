cask "font-um-typewriter" do
  version "001.003"

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
