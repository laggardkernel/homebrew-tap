class ClashPremium < Formula
  on_mojave :or_older do
    # https://github.com/Dreamacro/clash/issues/2599
    version "2023.01.29"
    livecheck do
      skip "Legacy version, last with 'redir-host' and works for Mojave"
    end
  end
  on_catalina :or_newer do
    version "2023.08.17"
    livecheck do
      skip "Unmaintained"
      # url :homepage
      # regex(%r{href=.+?/releases/download/premium/[^"]+(\d{4}[.-]\d{2}[.-]\d{2})}i)
      # url "https://release.dreamacro.workers.dev/"
      # regex(%r{href="(\d{4}[.-]\d{2}[.-]\d{2})[^"]*}i)
      # strategy :page_match do |page, regex|
      #   page.scan(regex).flatten.uniq.sort
      # end
    end
  end
  revision 2

  desc "Rule-based tunnel in Go, the pre-built premium version"
  homepage "https://github.com/Dreamacro/clash/releases/tag/premium"
  license "GPL-3.0"

  if OS.mac? && Hardware::CPU.intel?
    # url "https://release.dreamacro.workers.dev/#{version}/clash-darwin-amd64-#{version}.gz"
    # url "https://github.com/Dreamacro/clash/releases/download/premium/clash-darwin-amd64-#{version}.gz"
    url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/clash-darwin-amd64-#{version}.gz"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/clash-darwin-arm64-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is-64-bit?
    url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/clash-linux-amd64-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is-32-bit?
    url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/clash-linux-386-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-64-bit?
    url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/clash-linux-armv8-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-32-bit?
    url "https://github.com/zhongfly/Clash-premium-backup/releases/download/Premium-#{version}/clash-linux-armv7-#{version}.gz"
  end

  # resource will auto unpacked
  resource "clash-dashboard" do
    # folder name: clash-dashboard-gh-pages
    # url "https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.tar.gz"
    # url "https://github.com/chmod777john/clash-dashboard/archive/refs/heads/master.zip"
    # url "https://github.com/chmod777john/clash-dashboard/archive/9a32d9d.zip"
    url "https://github.com/hgl/clash-dashboard/archive/gh-pages.tar.gz"
  end

  resource "yacd" do
    # folder name: yacd-gh-pages
    url "https://github.com/haishanh/yacd/archive/gh-pages.tar.gz"
  end

  resource "mmdb" do
    # Alternative: alecthw/mmdb_china_ip_list, which has global support
    # url "https://cdn.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/Country.mmdb"
    url "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb"
  end

  def install
    # binary name: clash-darwin-amd64-2021.02.21
    bin.install Dir.glob("clash*")[0] => "clash"

    # Dashboards, one copy saved into share
    share_dst = "#{share}/clash"
    mkdir_p share_dst.to_s
    resource("clash-dashboard").stage do
      cp_r ".", "#{share_dst}/clash-dashboard"
    end
    resource("yacd").stage do
      cp_r ".", "#{share_dst}/yacd"
    end
    resource("mmdb").stage do
      cp "Country.mmdb", "#{share_dst}/"
    end

    # Another copy of the dashboard, to be installed into etc later
    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp

    Dir.chdir(etc_temp.to_s) do
      config_path = etc/"clash"
      [
        "clash-dashboard",
        "yacd",
        "Country.mmdb",
      ].each do |dst|
        # Skip saving as *.default, overwrite existing dashboards directly
        # dst_default = config_path/"#{dst}.default"
        # rm dst_default if dst_default.exist?
        config_path.install dst
      end
    end
    rm_rf etc_temp.to_s
  end

  def post_install
    (var/"log/clash").mkpath
    chmod 0755, var/"log/clash"
  end

  def caveats
    <<~EOS
      Homebrew services are run as LaunchAgents by current user.
      To start TUN mode, Clash should be run as a privileged service,
      you need to run it as a "global" daemon from /Library/LaunchAgents.

        sudo cp -f #{launchd_service_path} /Library/LaunchAgents/

      If you prefer using `sudo brew services`. Run `brew fix-perm` after it
      to fix the ruin file permissions.

      A global conf folder `#{HOMEBREW_PREFIX}/etc/clash` is created, with prebuilt
      dashboard static files. Before you start the launchd service, put a conf
      `config.yaml` and start the service once manually to download MMDB.
    EOS
  end

  service do
    require_root true
    run [opt_bin/"clash", "-d", etc/"clash"]
    # keep_alive { succesful_exit: true }
    working_dir etc/"clash"
    log_path var/"log/clash/clash.log"
    error_log_path var/"log/clash/clash.log"
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
    system "#{bin}/clash", "-t", "-d", testpath # test config && download Country.mmdb
    client = fork { exec "#{bin}/clash", "-d", testpath }

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
