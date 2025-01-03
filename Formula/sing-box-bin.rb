class SingBoxBin < Formula
  desc "Universal proxy platform"
  homepage "https://sing-box.sagernet.org"
  version "1.10.6"
  license "GPL-3.0-or-later"

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  conflicts_with "sing-box", because: "they are variants of the same package"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    # using `:homebrew_curl` to work around audit failure from TLS 1.3-only homepage
    url "https://github.com/SagerNet/sing-box/archive/refs/tags/v#{version}.tar.gz", using: :homebrew_curl
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/SagerNet/sing-box.git", tag: "v#{version}"
    depends_on "go" => :build
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-darwin-arm64.tar.gz"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-darwin-amd64.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-linux-amd64.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-32-bit?)
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-linux-armv7.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-64-bit?)
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-linux-arm64.tar.gz"
  end

  resource "config.json" do
    url "https://raw.githubusercontent.com/SagerNet/sing-box/main/release/config/config.json"
  end

  def install
    if build.without?("prebuilt") || build.head?
      version_str = version.to_s

      ldflags = "-s -w -X github.com/sagernet/sing-box/constant.Version=#{version_str} -buildid="
      # tags = "with_gvisor,with_quic,with_wireguard,with_utls,with_reality_server,with_clash_api"
      tags = "with_gvisor,with_quic,with_dhcp,with_wireguard,with_ech," \
             "with_utls,with_reality_server,with_acme,with_clash_api"
      system "go", "build", "-tags", tags, *std_go_args(ldflags:), "./cmd/sing-box"
    else
      bin.install "sing-box"
    end
    prefix.install_metafiles
    generate_completions_from_executable(bin/"sing-box", "completion")

    share_dst = "#{share}/sing-box"
    mkdir_p share_dst.to_s
    resource("config.json").stage do
      cp "config.json", "#{share_dst}/"
      config_path = etc/"sing-box"
      [
        "config.json",
      ].each do |dst|
        config_path.install dst # be renamed as .default if conflict
      end
    end
  end

  def post_install
    (var/"log/sing-box-bin").mkpath
    chmod 0755, var/"log/sing-box-bin"
  end

  service do
    run [opt_bin/"sing-box", "run", "-C", etc/"sing-box", "--disable-color"]
    run_type :immediate
    keep_alive true
    working_dir etc/"sing-box"
    log_path var/"log/sing-box-bin/sing-box.log"
    error_log_path var/"log/sing-box-bin/sing-box.log"
  end

  test do
    ss_port = free_port
    (testpath/"shadowsocks.json").write <<~EOS
      {
        "inbounds": [
          {
            "type": "shadowsocks",
            "listen": "::",
            "listen_port": #{ss_port},
            "method": "2022-blake3-aes-128-gcm",
            "password": "8JCsPssfgS8tiRwiMlhARg=="
          }
        ]
      }
    EOS
    server = fork { exec "#{bin}/sing-box", "run", "-D", testpath, "-c", testpath/"shadowsocks.json" }

    sing_box_port = free_port
    (testpath/"config.json").write <<~EOS
      {
        "inbounds": [
          {
            "type": "mixed",
            "listen": "::",
            "listen_port": #{sing_box_port}
          }
        ],
        "outbounds": [
          {
            "type": "shadowsocks",
            "server": "127.0.0.1",
            "server_port": #{ss_port},
            "method": "2022-blake3-aes-128-gcm",
            "password": "8JCsPssfgS8tiRwiMlhARg=="
          }
        ]
      }
    EOS
    system bin/"sing-box", "check", "-D", testpath, "-c", "config.json"
    client = fork { exec "#{bin}/sing-box", "run", "-D", testpath, "-c", "config.json" }

    sleep 3
    begin
      system "curl", "--socks5", "127.0.0.1:#{sing_box_port}", "github.com"
    ensure
      Process.kill 9, server
      Process.wait server
      Process.kill 9, client
      Process.wait client
    end
  end
end
