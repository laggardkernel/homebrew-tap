class BingWallpaper < Formula
  desc "Bing.com wallpaper for OS X, and any Unix like desktop"
  homepage "https://github.com/thejandroman/bing-wallpaper"
  head "https://github.com/thejandroman/bing-wallpaper.git"

  bottle :unneeded

  depends_on "bash" if MacOS.version >= :mojave

  def install
    bin.install "bing-wallpaper.sh" => "bing-wallpaper"
  end

  test do
    system "#{bin}/bing-wallpaper --version"
  end

  def caveats; <<~EOS
    BingWallpaper service is run every 4 hours to download pictures
    from bing and set them as wallpaper. The default picture storage
    location is $HOME/Pictures/bing-wallpapers/.

    Check 'bing-wallpaper -h' and modify the service plist for customization.
  EOS
  end

  plist_options :startup => true

  def plist; <<~EOS
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
end

