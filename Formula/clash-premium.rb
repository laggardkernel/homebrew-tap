class ClashPremium < Formula
  desc "Rule-based tunnel in Go, the pre-built premium version"
  homepage "https://github.com/Dreamacro/clash/releases/tag/premium"
  version "2022.05.18"
  license "GPL-3.0"

  livecheck do
    url :homepage
    regex(/(\d{4}[.-]\d{2}[.-]\d{2})/i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  if OS.mac? && Hardware::CPU.intel?
    url "https://release.dreamacro.workers.dev/#{version}/clash-darwin-amd64-#{version}.gz"
    # url "https://github.com/Dreamacro/clash/releases/download/premium/clash-darwin-amd64-#{version}.gz"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://release.dreamacro.workers.dev/#{version}/clash-darwin-arm64-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is-64-bit?
    url "https://release.dreamacro.workers.dev/#{version}/clash-linux-amd64-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is-32-bit?
    url "https://release.dreamacro.workers.dev/#{version}/clash-linux-386-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-64-bit?
    url "https://release.dreamacro.workers.dev/#{version}/clash-linux-armv8-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-32-bit?
    url "https://release.dreamacro.workers.dev/#{version}/clash-linux-armv7-#{version}.gz"
  end

  # resource will auto unpacked
  resource "clash-dashboard" do
    # folder name: clash-dashboard-gh-pages
    url "https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.tar.gz"
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
      To start TUN mode, clash should be run as a privileged service,
      you need to run it as a "global" daemon from /Library/LaunchAgents.

        sudo cp -f #{plist_path} /Library/LaunchAgents/

      If you prefer using `sudo brew services`. Run `brew fix-perm` after it
      to fix the ruin file permissions.

      A global conf folder `/usr/local/etc/clash` is created, with prebuilt
      dashboard static files. Before you start the launchd service, put a conf
      `config.yaml` and start the service once manually to download MMDB.
    EOS
  end

  plist_options manual: "clash -d #{HOMEBREW_PREFIX}/etc/clash"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
            <array>
              <string>#{opt_bin}/clash</string>
              <string>-d</string>
              <string>#{etc}/clash</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
            <key>StandardOutPath</key>
            <string>#{var}/log/clash/clash.log</string>
            <key>StandardErrorPath</key>
            <string>#{var}/log/clash/clash.log</string>
          </dict>
      </plist>
    EOS
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
