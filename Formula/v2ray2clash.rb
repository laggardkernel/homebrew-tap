require "language/go"

class V2ray2clash < Formula
  desc "Convert V2ray, SSR subscriptions to Clash subscriptions"
  homepage "https://github.com/ne1llee/v2ray2clash"
  head "https://github.com/ne1llee/v2ray2clash.git"
  url "https://github.com/ne1llee/v2ray2clash/archive/v1.0.5.tar.gz"
  sha256 "6346ed47dd24d5e274893f6962e8b944f154b9df54faeddded6fa90171f2bc19"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    path = buildpath/"src/github.com/ne1llee/v2ray2clash"
    path.install Dir["*"]

    cd path do
      system "go", "build", "-o", bin/"clashconfig"

      prefix.install_metafiles
      bin.install_symlink bin/"clashconfig" => "v2ray2clash"

      # location for template storage
      (etc/"v2ray2clash").mkpath
    end
  end

  test do
    system bin/"clashconfig", "--help"
  end


  def caveats; <<~EOS
    It's very weird that the author choose a different repo name with the executable.
    The repo is named v2ray2clash, but the executable is named clashconfig.

    To fix this, executable clashconfig is symlinked as v2ray2clash.

    When the daemon starts, it downloads a conf template under the current working dir.
    LaunchAgent started by plist saves the template into #{etc}/v2ray2clash.

    Port 5050 is taken by the clashconfig daemon by default.
    If you would like to change these settings, start the daemon manually with options,
    or edit the plist file before enable the service.

      #{plist_path}

    Usage:
      http://127.0.0.1:5050/v2ray2clash?sub_link=foobar
      http://127.0.0.1:5050/ssr2clashr?sub_link=foobar
      http://127.0.0.1:5050/v2ray2qunx?sub_link=foobar

    Open the link in a browser, or download the output rule file with curl,
      curl http://127.0.0.1:5050/v2ray2clash?sub_link=foobar -o clash.conf
  EOS
  end

  plist_options :manual => "clashconfig -l 127.0.0.1 -p 5050"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/clashconfig</string>
        <string>-l</string>
        <string>127.0.0.1</string>
        <string>-p</string>
        <string>5050</string>
      </array>
      <key>KeepAlive</key>
      <dict>
        <key>SuccessfulExit</key>
        <false/>
      </dict>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{etc}/v2ray2clash</string>
    </dict>
    </plist>
    EOS
  end

end
