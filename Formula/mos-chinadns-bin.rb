class MosChinadnsBin < Formula
  desc "Cross-platform DNS routing app"
  homepage "https://github.com/IrineSistiana/mos-chinadns"
  version "1.5.6"
  url "https://github.com/IrineSistiana/mos-chinadns/releases/download/v1.5.6/mos-chinadns-darwin-amd64.zip"
  sha256 "6bd6d24ef72d743ee67dcfa193c3e8875b1740f4c2e6c583a5345b9f15eb20f4"

  def install
    bin.install "mos-chinadns"

    mkdir_p "etc/mos-chinadns"
    cp_r Dir["*.list"], "etc/mos-chinadns/"
    cp_r Dir["*.yaml"], "etc/mos-chinadns/"
    etc.install "etc/mos-chinadns"

    # Make a backup of confs into share
    mkdir_p "etc/mos-chinadns"
    cp_r Dir["*.list"], "etc/mos-chinadns/"
    cp_r Dir["*.yaml"], "etc/mos-chinadns/"
    share.install Dir["etc/mos-chinadns"]
  end

  test do
    system "#{bin}/mos-chinadns", "-v"
  end

  def caveats; <<~EOS
    Homebrew services are run as LaunchAgents by current user.
    To make mos-chinadns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "mos-chinadns -c /usr/local/etc/mos-chinadns/config.yaml"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>KeepAlive</key>
        <dict>
            <key>SuccessfulExit</key>
            <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/mos-chinadns</string>
            <string>-c</string>
            <string>#{etc}/mos-chinadns/config.yaml</string>
            <string>-dir</string>
            <string>#{etc}/mos-chinadns</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
  EOS
  end
end
