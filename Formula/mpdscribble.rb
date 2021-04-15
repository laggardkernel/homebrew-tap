class Mpdscribble < Formula
  desc "Last.fm reporting client for mpd"
  homepage "https://musicpd.org/clients/mpdscribble/"
  url "https://www.musicpd.org/download/mpdscribble/0.23/mpdscribble-0.23.tar.xz"
  sha256 "a3387ed9140eb2fca1ccaf9f9d2d9b5a6326a72c9bcd4119429790c534fec668"
  license all_of: ["GPL-2.0-only", "GPL-2.0-or-later"]
  head "https://github.com/MusicPlayerDaemon/mpdscribble.git"

  livecheck do
    url "https://musicpd.org/clients/mpdscribble/"
    regex(/mpdscribble-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle :unneeded

  depends_on "boost" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "libgcrypt"
  depends_on "libmpdclient"
  depends_on "libsoup"

  def install
    args = std_meson_args + "--sysconfdir=#{etc}"

    mkdir "build" do
      system "meson", *args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  def caveats
    <<~EOS
      The configuration file was placed in #{etc}/mpdscribble.conf
    EOS
  end

  plist_options manual: "mpdscribble"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>WorkingDirectory</key>
          <string>#{HOMEBREW_PREFIX}</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{opt_bin}/mpdscribble</string>
              <string>--no-daemon</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <true/>
      </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/mpdscribble", "--version"
  end
end
