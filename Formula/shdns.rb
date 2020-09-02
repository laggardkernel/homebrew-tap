require "language/go"

class Shdns < Formula
  desc "A port of ChinaDNS (DNS filter) in golang with IPv6 support"
  homepage "https://github.com/domosekai/shdns"
  url "https://github.com/domosekai/shdns/archive/v0.8.1.tar.gz"
  sha256 "6d93a2b4612d10d49f87a665c058976a2e943900e314598efce9fefb91a1f96c"
  head "https://github.com/domosekai/shdns.git"

  depends_on "go" => :build

  go_resource "golang.org/x/net" do
    # https://go.googlesource.com/net.git/+/refs/heads/release-branch.go1.15
    url "https://go.googlesource.com/net.git",
      :revision => "ab34263943818b32f575efc978a3d24e80b04bd7"
  end

  def install
    ENV["GOPATH"] = buildpath
    path = buildpath/"src/github.com/domosekai/shdns"
    path.install Dir["*"]
    Language::Go.stage_deps resources, buildpath/"src"

    cd path do
      system "go", "build", "-o", bin/"shdns"

      # bin.install "shdns" # replaced by
      prefix.install_metafiles
      (etc/"shdns").mkpath
      etc.install "cnipv4.txt" => "shdns/cnipv4.txt"
      etc.install "cnipv6.txt" => "shdns/cnipv6.txt"
    end
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
