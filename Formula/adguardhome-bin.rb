class AdguardhomeBin < Formula
  desc "Network-wide ads & trackers blocking DNS server"
  homepage "https://github.com/AdguardTeam/AdGuardHome"
  version "0.105.1"
  url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_darwin_amd64.zip"
  sha256 "81d900fc962d7e567c7a24925dc52ca71e57b6fda4adb5ae64671aaf3787dd8b"

  conflicts_with "adguardhome", :because => "same package"

  def install
    # TODO: lowercase?
    bin.install "AdGuardHome"
    prefix.install_metafiles
    mkdir_p etc/"adguardhome"
  end

  def post_install
    (var/"log/adguardhome").mkpath
    chmod 0755, var/"log/adguardhome"
  end

  def caveats; <<~EOS
    https://github.com/AdguardTeam/AdGuardHome/wiki/Getting-Started.
    Recommend saving config in #{etc}/adguardhome dir.

      sudo AdGuardHome -w #{etc}/adguardhome

    AdGuardHome executable could control the launchd service by itself.

      sudo AdGuardHome -w #{etc}/adguardhome -s start
      sudo AdGuardHome -w #{etc}/adguardhome -s stop

    which conflicts the launchd profile provided by this formula.

    Caveat: use `sudo` if AdGuardHome listens at a privileged port.
    If the service is started with `sudo` `brew services`. Run `brew fix-perm`
    to fix the broken file perms.
  EOS
  end

  # #{etc} is not supported here
  plist_options :manual => "sudo AdGuardHome -w /usr/local/etc/adguardhome"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/AdGuardHome</string>
        <string>-w</string>
        <string>#{etc}/adguardhome</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{etc}/adguardhome</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/adguardhome/adguardhome.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/adguardhome/adguardhome.log</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <dict>
        <key>SuccessfulExit</key>
        <false/>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/AdGuardHome", "--version"
  end

end
