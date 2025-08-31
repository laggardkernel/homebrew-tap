class ClashMetaBin < Formula
  desc "Rule-based tunnel in Go, the forked one Clash.Meta"
  # homepage "https://github.com/MetaCubeX/Clash.Meta"
  homepage "https://github.com/MetaCubeX/mihomo"
  version "1.19.13"
  license "GPL-3.0"

  livecheck do
    url "https://github.com/MetaCubeX/mihomo/releases" # rubocop: disable all
    regex(%r{href=".*?/releases/tag/v?(\d+(?:\.\d+)+)"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  # Repo name was renamed from Clash.Meta to mihomo since 1.17.0
  if OS.mac? && Hardware::CPU.intel?
    # TODO(lk): what about the 'cgo' variant
    # url "https://github.com/MetaCubeX/Clash.Meta/releases/download/v#{version}/clash.meta-darwin-amd64-v#{version}.gz"
    url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-darwin-amd64-v#{version}.gz"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-darwin-arm64-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && (Hardware::CPU.is-64-bit?)
    # TODO(lk): 'compatible' variant?
    url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-linux-amd64-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && (Hardware::CPU.is-32-bit?)
    url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-linux-386-cgo-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-64-bit?)
    url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-linux-arm64-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-32-bit?)
    url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-linux-armv7-v#{version}.gz"
  end

  resource "zashboard" do
    # url: https://board.zash.run.place/
    # folder: dist.zip
    # rubocop: disable all
    url "https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip"
    # rubocop: enable all
  end

  resource "metacubexd" do
    # url: https://d.metacubex.one/, ~~https://metacubex.github.io/metacubexd~~
    # folder: compressed-dist.tgz
    url "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
  end

  # resource will auto unpacked
  resource "clash-dashboard" do
    # url: https://clash.metacubex.one/, https://metacubex.github.io/Razord-meta
    # folder: Razord-meta-gh-pages.tar.gz
    url "https://github.com/MetaCubeX/Razord-meta/archive/gh-pages.tar.gz" # rubocop: disable all
  end

  resource "yacd" do
    # url: https://yacd.metacubex.one/, https://metacubex.github.io/Yacd-meta
    # folder: Yacd-meta-gh-pages.tar.gz
    url "https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.tar.gz" # rubocop: disable all
  end

  resource "mmdb" do
    # Alternative: alecthw/mmdb_china_ip_list, which has global support
    # url "https://cdn.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/Country.mmdb"
    # url "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb"
    url "https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/Country-without-asn.mmdb"
  end

  def install
    # binary name: clash.meta-darwin-amd64-v1.14.2
    bin.install Dir.glob(["mihomo*", "clash.meta*"])[0] => "clash-meta"

    # Dashboards, one copy saved into share
    share_dst = "#{share}/clash-meta"
    mkdir_p share_dst.to_s
    %w[zashboard metacubexd clash-dashboard yacd].each do |name|
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
      config_path = etc/"clash-meta"
      %w[zashboard metacubexd clash-dashboard yacd Country.mmdb].each do |dst|
        # Skip saving as *.default, overwrite existing dashboards directly
        # dst_default = config_path/"#{dst}.default"
        # rm dst_default if dst_default.exist?
        config_path.install dst
      end
    end
    rm_r(etc_temp.to_s)
  end

  def post_install
    (var/"log/clash-meta").mkpath
    chmod 0755, var/"log/clash-meta"
  end

  def caveats
    <<~EOS
      Homebrew services are run as LaunchAgents by current user.
      To start TUN mode, Clash.Meta should be run as a privileged service,
      you need to run it as a "global" daemon from /Library/LaunchAgents.

        sudo cp -f #{launchd_service_path} /Library/LaunchAgents/

      If you prefer using `sudo brew services`. Run `brew fix-perm` after it
      to fix the ruin file permissions.

      A global conf folder `#{HOMEBREW_PREFIX}/etc/clash-meta` is created, with prebuilt
      dashboard static files. Before you start the launchd service, put a conf
      `config.yaml` and start the service once manually to download MMDB.
    EOS
  end

  service do
    require_root true
    run [opt_bin/"clash-meta", "-d", etc/"clash-meta"]
    # keep_alive { succesful_exit: true }
    working_dir etc/"clash-meta"
    log_path var/"log/clash-meta/clash.log"
    error_log_path var/"log/clash-meta/clash.log"
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
    system bin/"clash-meta", "-t", "-d", testpath # test config && download Country.mmdb
    client = fork { exec "#{bin}/clash-meta", "-d", testpath }

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
