class BingWallpaper < Formula
  desc "Bing.com wallpaper for OS X, and any Unix like desktop"
  homepage "https://github.com/thejandroman/bing-wallpaper"
  version "c84271c"
  url "https://github.com/thejandroman/bing-wallpaper/archive/#{version}.tar.gz"
  # sha256 ""
  head "https://github.com/thejandroman/bing-wallpaper.git"
  license "GPL-3.0"

  livecheck do
    url "https://github.com/thejandroman/bing-wallpaper/commits/master/bing-wallpaper.sh"
    regex(%r{href="/thejandroman/bing-wallpaper/tree/([a-z0-9]{7,}+)" })
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  bottle :unneeded

  # depends_on "bash" if MacOS.version >= :mojave

  def install
    bin.install "bing-wallpaper.sh" => "bing-wallpaper"
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      BingWallpaper service is run every 4 hours to download pictures
      from bing and set them as wallpaper. The default picture storage
      location is $HOME/Pictures/bing-wallpapers/.

      Check 'bing-wallpaper -h' and modify the service plist for customization.
    EOS
  end

  plist_options startup: true
  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{opt_bin}/bing-wallpaper</string>
              <string>-s</string>
              <string>-w</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>StartInterval</key>
          <integer>14400</integer>
      </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/bing-wallpaper", "--version"
  end
end
