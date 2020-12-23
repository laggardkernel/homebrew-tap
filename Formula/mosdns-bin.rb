class MosdnsBin < Formula
  desc "Flexible forwarding DNS client"
  homepage "https://github.com/IrineSistiana/mosdns"
  version "0.17.1"
  url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-darwin-amd64.zip"
  sha256 "6143e2c7f74fe0d128bf19d15a13518729aee28a62af6f62d0a9aa1a70c54ef7"

  conflicts_with "mosdns", :because => "same package"

  resource "china_ip_list" do
    url "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
  end

  def install
    bin.install "mosdns"

    # rename config-template.yaml
    mv "config-template.yaml", "config.yaml"
    share_dst = "#{prefix}/share/mosdns"
    mkdir_p "#{share_dst}"
    cp_r Dir["*.list"], "#{share_dst}/"
    cp_r Dir["*.yaml"], "#{share_dst}/"
    resource("china_ip_list").stage {
      cp "china_ip_list.txt", "#{share_dst}/"
    }

    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp
    # Conf installation borrowed from php.rb
    Dir.chdir("#{etc_temp}") do
      config_path = etc/"mosdns"
      Dir.glob(["*.yaml", "*.list", "*.txt"]).each do |dst|
        dst_default = config_path/"#{dst}.default"
        rm dst_default if dst_default.exist?
        config_path.install dst
      end
    end
    rm_rf "#{etc_temp}"
  end

  test do
    system "#{bin}/mosdns", "-v"
  end

  def caveats; <<~EOS
    Homebrew services are run as LaunchAgents by current user.
    To make mosdns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "mosdns -dir /usr/local/etc/mosdns -c /usr/local/etc/mosdns/config.yaml"

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
            <string>#{opt_bin}/mosdns</string>
            <string>-dir</string>
            <string>#{etc}/mosdns</string>
            <string>-c</string>
            <string>#{etc}/mosdns/config.yaml</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
  EOS
  end
end
