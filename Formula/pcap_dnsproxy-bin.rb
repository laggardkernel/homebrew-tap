class PcapDnsproxyBin < Formula
  desc "Powerful DNS proxy designed to anti DNS spoofing"
  # homepage "https://github.com/chengr28/Pcap_DNSProxy"
  homepage "https://github.com/Lyoko-Jeremie/Pcap_DNSProxy"
  url "https://github.com/Lyoko-Jeremie/Pcap_DNSProxy_release/raw/master/Pcap_DNSProxy-0.4.9.13-bin.zip"
  sha256 "da19a7a9cbec399fabbac03da7238120d984d1175ab2361a02f6f4de1275afc7"
  # head "https://github.com/Lyoko-Jeremie/Pcap_DNSProxy.git"

  bottle :unneeded

  depends_on :macos => :el_capitan
  # depends_on :xcode => :build
  # depends_on "libsodium"
  # depends_on "openssl@1.1"

  def install
    bin.install "macOS/Pcap_DNSProxy"

    # Rename ext .conf to .ini, the later ext is used in
    # the original formula "pcap_dnsproxy"
    Dir.chdir("macOS") do
      Dir.glob(["*.conf"]).each do |i|
        mv i, i.split(".")[0] + ".ini"
      end
    end

    # Make a copy saved into share
    share_dst = "#{prefix}/share/pcap_dnsproxy"
    mkdir_p "#{share_dst}"
    cp Dir["macOS/*.{ini,txt,conf}"], "#{share_dst}/"

    cp Dir["macOS/Tools/*.sh"], "#{share_dst}/"
    cp_r Dir["Documents"], "#{share_dst}/"

    (etc/"pcap_dnsproxy").install Dir["macOS/*.{ini,txt,conf}"]
    (etc/"pcap_dnsproxy").install Dir["macOS/Tools/*.sh"]
  end

  def post_install
    (var/"log/pcap_dnsproxy").mkpath
    chmod 0755, var/"log/pcap_dnsproxy"
  end

  def caveats; <<~EOS
    Homebrew services are run as LaunchAgents by current user.
    To make the daemon listen on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Or use `sudo` with `brew services`. But remember to run `brew fix-perm`
    to fix related file owner back as current user.
  EOS
  end

  plist_options :manual => "sudo Pcap_DNSProxy -c #{HOMEBREW_PREFIX}/etc/pcap_dnsproxy/"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/Pcap_DNSProxy</string>
        <string>-c</string>
        <string>#{etc}/pcap_dnsproxy/</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{etc}/pcap_dnsproxy</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/pcap_dnsproxy/pcap_dnsproxy.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/pcap_dnsproxy/pcap_dnsproxy.log</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <dict>
        <key>SuccessfulExit</key>
        <false/>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>10240</integer>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    (testpath/"pcap_dnsproxy").mkpath
    cp Dir[etc/"pcap_dnsproxy/*"], testpath/"pcap_dnsproxy/"

    inreplace testpath/"pcap_dnsproxy/Config.ini" do |s|
      s.gsub! /^Direct Request.*/, "Direct Request = IPv4 + IPv6"
      s.gsub! /^Operation Mode.*/, "Operation Mode = Proxy"
      s.gsub! /^Listen Port.*/, "Listen Port = 9999"
    end

    pid = fork { exec bin/"Pcap_DNSProxy", "-c", testpath/"pcap_dnsproxy/" }
    begin
      system "dig", "google.com", "@127.0.0.1", "-p", "9999", "+short"
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end

# https://github.com/Homebrew/homebrew-core/pull/19121
# https://github.com/ilovezfs/homebrew-core/blob/0076ea375d848f8fe152edb58022cb4f2083fbf2/Formula/pcap_dnsproxy.rb
# https://github.com/Homebrew/homebrew-core/pull/16973
# https://github.com/Homebrew/homebrew-core/blob/b532ae4e8716f4fe8e8362667f6d15a234789cd1/Formula/pcap_dnsproxy.rb
