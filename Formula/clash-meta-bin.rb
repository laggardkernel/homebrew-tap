class ClashMetaBin < Formula
  desc "Rule-based tunnel in Go, the forked one Clash.Meta"
  # homepage "https://github.com/MetaCubeX/Clash.Meta"
  homepage "https://github.com/MetaCubeX/mihomo"
  version "1.19.19"
  license "GPL-3.0"

  livecheck do
    url "https://github.com/MetaCubeX/mihomo/releases" # rubocop: disable all
    regex(%r{href=".*?/releases/tag/v?(\d+(?:\.\d+)+)"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  # Repo name was renamed from Clash.Meta to mihomo since 1.17.0
  os_name = OS.mac? ? "darwin" : "linux"
  if Hardware::CPU.intel?
    cpu_arch = Hardware::CPU.is_64_bit? ? "amd64" : "386"
  elsif Hardware::CPU.arm?
    cpu_arch = Hardware::CPU.is_64_bit? ? "arm64" : "armv7"
  end
  # https://en.wikipedia.org/wiki/X86-64#Microarchitecture_levels
  cpu_level = ""
  if Hardware::CPU.intel?
    if Hardware::CPU.sysctl_bool!("hw.optional.avx512f")
      # x86-64-v4: AVX-512 Foundation
      cpu_level = ""
    elsif Hardware::CPU.avx2?
      # x86-64-v3: AVX2
      cpu_level = "v3"
    elsif Hardware::CPU.sse4_2?
      # x86-64-v2 level (SSE4.2 support)
      cpu_level = "v2"
    else
      # Basic x86-64-v1 level
      cpu_level = "v1"
    end
  end
  go_str = ""
  if OS.mac?
    if MacOS.version > "11"
      go_str = ""
    elsif MacOS.version > "10.15"
      go_str = "go124"
    elsif MacOS.version > "10.13"
      go_str = "go122"
    else
      go_str = "go120"
    end
  end
  # mohomo-{os_name}-{cpu_arch}-{cpu_level}-{go_str}-v{version}.gz
  # name_middle_part = [os_name, cpu_arch, cpu_level, go_str].join('-')
  name_middle = [os_name, cpu_arch, cpu_level, go_str].reject(&:empty?).join('-')
  url "https://github.com/MetaCubeX/mihomo/releases/download/v#{version}/mihomo-#{name_middle}-v#{version}.gz"

  resource "config.yaml" do
    url "https://github.com/MetaCubeX/mihomo/raw/refs/heads/Meta/docs/config.yaml"
  end

  def install
    # binary name: clash.meta-darwin-amd64-v1.14.2
    bin.install Dir.glob(["mihomo*", "clash.meta*"])[0] => "clash-meta"

    share_dst = "#{share}/clash-meta"
    mkdir_p share_dst.to_s
    config_path = etc/"clash-meta"
    %w[config.yaml].each do |name|
      resource(name).stage do
        cp_r name.to_s, "#{share_dst}/"
        config_path.install name.to_s # be renamed as .default if conflict
      end
    end
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
      `config.yaml` and start the service.
    EOS
  end

  service do
    require_root true
    run [opt_bin/"clash-meta", "-d", etc/"clash-meta"]
    keep_alive successful_exit: true
    working_dir etc/"clash-meta"
    # log_path var/"log/clash-meta/clash.log"
    # error_log_path var/"log/clash-meta/clash.log"
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
