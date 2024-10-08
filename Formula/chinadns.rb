class Chinadns < Formula
  desc "Port of ChinaDNS to C: fix irregularities with DNS in China"
  homepage "https://github.com/aa65535/ChinaDNS"
  # rubocop: disable all
  version "1.3.3"
  url "https://github.com/aa65535/ChinaDNS/archive/v#{version}.tar.gz"
  # rubocop: enable all
  sha256 "74e53af32f8aa2ca7e63697385f12d89a06c486641556cfd8bc3f085d87e55ad"
  revision 2

  head "https://github.com/aa65535/ChinaDNS.git"

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
    # etc.install "#{share}" => "chinadns"
    # chnroute.txt, iplist.txt
    share_dst = "#{share}/chinadns"
    mkdir_p share_dst
    mv Dir["#{share}/*.txt"], "#{share_dst}/"
    resource("china_ip_list").stage do
      cp "china_ip_list.txt", "#{share_dst}/"
    end
    resource("geoip2-cn-txt").stage do
      cp "CN-ip-cidr.txt", "#{share_dst}/"
    end

    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp
    # Conf installation borrowed from php.rb
    Dir.chdir(etc_temp.to_s) do
      config_path = etc/"chinadns"
      Dir.glob(["*.txt"]).each do |dst|
        dst_default = config_path/"#{dst}.default"
        rm dst_default if dst_default.exist?
        rm config_path/dst.to_s if (config_path/dst.to_s).exist?
        config_path.install dst
      end
    end
    rm_r(etc_temp.to_s)
  end

  def caveats
    <<~EOS
      It's not recommended to run ChinaDNS alone. A forwarding DNS server
      with cache support, like dnsmasq or unbound, should be put before it.

      Caveat: port 5353 is taken by mDNSResponder. ChinaDNS runs on
      localhost (127.0.0.1), port 5300, balancing traffic across a set of resolvers.
      If you would like to change these settings, edit the plist service file.

      Homebrew services are run as LaunchAgents by current user.
      To make chinadns service work on privileged port, like port 53,
      you need to run it as a "global" daemon in /Library/LaunchAgents.

        sudo cp -f #{launchd_service_path} /Library/LaunchAgents/

      Dont' use `sudo brew services`. This very command will ruin the file perms.
    EOS
  end

  service do
    run [opt_bin/"chinadns", "-c", etc/"chinadns/chnroute.txt", "-b", "127.0.0.1", "-p", "5300", "-s",
         "114.114.114.114,208.67.222.222#443", "-m"]
    # keep_alive { succesful_exit: true }
  end

  test do
    system bin/"chinadns", "-h"
  end
end
