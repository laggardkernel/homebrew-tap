class Chinadns < Formula
  desc "Port of ChinaDNS to C: fix irregularities with DNS in China"
  homepage "https://github.com/aa65535/ChinaDNS"
  url "https://github.com/aa65535/ChinaDNS/archive/v1.3.3.tar.gz"
  sha256 "74e53af32f8aa2ca7e63697385f12d89a06c486641556cfd8bc3f085d87e55ad"
  revision 1

  head do
    url "https://github.com/aa65535/ChinaDNS.git"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  # TODO: drop one cidr list?
  resource "china_ip_list" do
    url "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
  end

  resource "geoip2-cn-txt" do
    url "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt"
  end

  def install
    system "./autogen.sh" # if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Config files are moved into prefix/"share" by installer, move it
    # etc.install "#{prefix}/share" => "chinadns"
    # chnroute.txt, iplist.txt
    share_dst = "#{prefix}/share/chinadns"
    mkdir_p share_dst
    mv Dir["#{prefix}/share/*.txt"], "#{share_dst}/"
    resource("china_ip_list").stage {
      cp "china_ip_list.txt", "#{share_dst}/"
    }
    resource("geoip2-cn-txt").stage {
      cp "CN-ip-cidr.txt", "#{share_dst}/"
    }

    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp
    # Conf installation borrowed from php.rb
    Dir.chdir("#{etc_temp}") do
      config_path = etc/"chinadns"
      Dir.glob(["*.txt"]).each do |dst|
        dst_default = config_path/"#{dst}.default"
        rm dst_default if dst_default.exist?
        config_path.install dst
      end
    end
    rm_rf "#{etc_temp}"
  end

  test do
    system "#{bin}/chinadns", "-h"
  end

  def caveats; <<~EOS
    It's not recommended to run ChinaDNS alone. A forwarding DNS server
    with cache support, like dnsmasq or unbound, should be put before it.

    Caveat: port 5353 is taken by mDNSResponder. ChinaDNS runs on
    localhost (127.0.0.1), port 5300, balancing traffic across a set of resolvers.
    If you would like to change these settings, edit the plist service file.

    Homebrew services are run as LaunchAgents by current user.
    To make chinadns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "chinadns -c /usr/local/etc/chinadns/chnroute.txt -b 127.0.0.1 -p 5300 -s 114.114.114.114,208.67.222.222#443 -m"

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
            <string>#{opt_bin}/chinadns</string>
            <string>-c</string>
            <string>#{etc}/chinadns/chnroute.txt</string>
            <string>-b</string>
            <string>127.0.0.1</string>
            <string>-p</string>
            <string>5300</string>
            <string>-s</string>
            <string>114.114.114.114,208.67.222.222#443</string>
            <string>-m</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
  EOS
  end
end
