class ShdnsBin < Formula
  desc "A port of ChinaDNS (DNS filter) in golang with IPv6 support"
  homepage "https://github.com/domosekai/shdns"
  url "https://github.com/domosekai/shdns/releases/download/v0.8.3/shdns-0.8.3-20201011-macos-amd64.tar.gz"
  sha256 "0eb53472a1c9410d93a5e33ca8b31d19985e1e5589df671303959eb10a14893c"
  head "https://github.com/domosekai/shdns.git"

  conflicts_with "shdns", :because => "both install `shdns` binaries"

  bottle :unneeded

  def install
    bin.install "shdns"
    # prefix.install_metafiles
    (etc/"shdns").mkpath
    etc.install "cnipv4.txt" => "shdns/cnipv4.txt"
    etc.install "cnipv6.txt" => "shdns/cnipv6.txt"
  end

  test do
    system bin/"shdns", "-h"
  end

  def caveats; <<~EOS
    It's not recommended to run shdns alone. A forwarding DNS server
    with cache support, like dnsmasq or unbound, should be put before it.

    Caveat: port 5353 is taken by mDNSResponder. Shdns runs on
    localhost (127.0.0.1), port 5300, balancing traffic across a set of resolvers.
    If you would like to change these settings, edit the plist service file.

    Homebrew services are run as LaunchAgents by current user.
    To make chinadns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "shdns -l4 /usr/local/etc/shdns/cnipv4.txt -l6 /usr/local/etc/shdns/cnipv4.txt -d 114.114.114.114,114.114.115.115 -f 208.67.222.222:443,208.67.222.220:443 -t -w 40 -b 127.0.0.1:5300"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/shdns</string>
          <string>-l4</string>
          <string>#{etc}/shdns/cnipv4.txt</string>
          <string>-l6</string>
          <string>#{etc}/shdns/cnipv6.txt</string>
          <string>-d</string>
          <string>114.114.114.114,114.114.115.115</string>
          <string>-f</string>
          <string>208.67.222.222:443,208.67.222.220:443</string>
          <string>-t</string>
          <string>-w</string>
          <string>40</string>
          <string>-b</string>
          <string>127.0.0.1:5300</string>
        </array>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end
end
