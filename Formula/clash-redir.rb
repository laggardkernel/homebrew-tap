class ClashRedir < Formula
  # https://github.com/Dreamacro/clash/issues/2599
  desc "Rule-based tunnel in Go, the pre-built premium version"
  homepage "https://github.com/Dreamacro/clash/releases/tag/premium"
  version "2023.01.29"
  license "GPL-3.0"
  revision 4

  livecheck do
    skip "Legacy version, last with 'redir-host' and works for Mojave"
  end

  os_name = OS.mac? ? "darwin" : "linux"
  if Hardware::CPU.intel?
    if OS.linux? && Hardware::CPU.is-32-bit?
      cpu_arch = "386"
    else
      cpu_arch = "amd64"
    end
  elsif Hardware::CPU.arm?
    if Hardware::CPU.is-64-bit? && OS.mac?
      cpu_arch = "arm64"
    elsif Hardware::CPU.is-64-bit? && OS.linux?
      cpu_arch = "armv8"
    else
      cpu_arch = "armv7"
    end
  end
  basename = "clash-#{os_name}-#{cpu_arch}-#{version}.gz"
  url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/#{basename}"

  # resource will auto unpacked
  resource "clash-dashboard" do
    # folder name: clash-dashboard-gh-pages
    # url "https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.tar.gz"
    # url "https://github.com/chmod777john/clash-dashboard/archive/refs/heads/master.zip"
    # url "https://github.com/chmod777john/clash-dashboard/archive/9a32d9d.zip"
    url "https://github.com/hgl/clash-dashboard/archive/gh-pages.tar.gz" # rubocop: disable all
  end

  resource "yacd" do
    # folder name: yacd-gh-pages
    url "https://github.com/haishanh/yacd/archive/gh-pages.tar.gz" # rubocop: disable all
  end

  resource "mmdb" do
    # Alternative: alecthw/mmdb_china_ip_list, which has global support
    # url "https://cdn.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/Country.mmdb"
    # url "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb"
    url "https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/Country-without-asn.mmdb"
  end

  def install
    # binary name: clash-darwin-amd64-2021.02.21
    bin.install Dir.glob("clash*")[0] => "clash-redir"

    # Dashboards, one copy saved into share
    share_dst = "#{share}/clash-redir"
    mkdir_p share_dst.to_s
    %w[clash-dashboard yacd].each do |name|
      resource(name).stage do
        cp_r ".", "#{share_dst}/#{name}"
      end
    end
    resource("mmdb").stage do
      cp Dir.glob("Country*.mmdb")[0], "#{share_dst}/Country.mmdb"
    end

    # Another copy of the dashboard, to be installed into etc later
    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp

    Dir.chdir(etc_temp.to_s) do
      config_path = etc/"clash-premium"
      %w[clash-dashboard yacd Country.mmdb].each do |dst|
        # Skip saving as *.default, overwrite existing dashboards directly
        # dst_default = config_path/"#{dst}.default"
        # rm dst_default if dst_default.exist?
        config_path.install dst
      end
    end
    rm_r(etc_temp.to_s)
  end

  def post_install
    (var/"log/clash-redir").mkpath
    chmod 0755, var/"log/clash-redir"
  end

  def caveats
    <<~EOS
      Homebrew services are run as LaunchAgents by current user.
      To start TUN mode, Clash should be run as a privileged service,
      you need to run it as a "global" daemon from /Library/LaunchAgents.

        sudo cp -f #{launchd_service_path} /Library/LaunchAgents/

      If you prefer using `sudo brew services`. Run `brew fix-perm` after it
      to fix the ruin file permissions.

      A global conf folder `#{HOMEBREW_PREFIX}/etc/clash-premium` is created, with prebuilt
      dashboard static files. Before you start the launchd service, put a conf
      `config-redir.yaml` and start the service once manually to download MMDB.
    EOS
  end

  service do
    require_root true
    run [opt_bin/"clash-redir", "-d", etc/"clash-premium", "-f", "config-redir.yaml"]
    # keep_alive { succesful_exit: true }
    working_dir etc/"clash-premium"
    # log_path var/"log/clash-redir/clash.log"
    # error_log_path var/"log/clash-redir/clash.log"
  end

  test do
    ss_port = free_port
    (testpath/"shadowsocks-libev.json").write <<~EOS
      {
          "server":"127.0.0.1",
          "server_port":#{ss_port},
          "password":"test",
          "timeout":600,
          "method":"chacha20-ietf-poly1305"
      }
    EOS
    server = fork { exec "ss-server", "-c", testpath/"shadowsocks-libev.json" }

    clash_port = free_port
    (testpath/"config.yaml").write <<~EOS
      mixed-port: #{clash_port}
      mode: global
      proxies:
        - name: "server"
          type: ss
          server: 127.0.0.1
          port: #{ss_port}
          password: "test"
          cipher: chacha20-ietf-poly1305
    EOS
    system bin/"clash-redir", "-t", "-d", testpath # test config && download Country.mmdb
    client = fork { exec "#{bin}/clash-redir", "-d", testpath }

    sleep 3
    begin
      system "curl", "--socks5", "127.0.0.1:#{clash_port}", "github.com"
    ensure
      Process.kill 9, server
      Process.wait server
      Process.kill 9, client
      Process.wait client
    end
  end
end
