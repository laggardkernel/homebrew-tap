class SingBoxBin < Formula
  desc "Universal proxy platform"
  homepage "https://sing-box.sagernet.org"
  version "1.12.14"
  license "GPL-3.0-or-later"

  conflicts_with "sing-box", because: "they are variants of the same package"

  os_name = OS.mac? ? "darwin" : "linux"
  if Hardware::CPU.intel?
    cpu_arch = "amd64"
  elsif Hardware::CPU.arm?
    cpu_arch = Hardware::CPU.is_64_bit? ? "arm64" : "armv7"
  end
  basename = "sing-box-#{version}-#{os_name}-#{cpu_arch}.tar.gz"
  url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/#{basename}"

  resource "config.json" do
    url "https://raw.githubusercontent.com/SagerNet/sing-box/main/release/config/config.json"
  end

  def install
    bin.install "sing-box"
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
    (var/"lib/sing-box").mkpath
    chmod 0755, var/"lib/sing-box"
    (var/"log/sing-box").mkpath
    chmod 0755, var/"log/sing-box"
  end

  service do
    run [opt_bin/"sing-box", "run", "-C", etc/"sing-box", "--disable-color"]
    run_type :immediate
    keep_alive true
    working_dir var/"lib/sing-box"
    # log_path var/"log/sing-box/sing-box.log"
    # error_log_path var/"log/sing-box/sing-box.log"
  end

  test do
    ss_port = free_port
    (testpath/"shadowsocks.json").write <<~JSON
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
    JSON
    server = fork { exec bin/"sing-box", "run", "-D", testpath, "-c", testpath/"shadowsocks.json" }

    sing_box_port = free_port
    (testpath/"config.json").write <<~JSON
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
    JSON
    system bin/"sing-box", "check", "-D", testpath, "-c", "config.json"
    client = fork { exec bin/"sing-box", "run", "-D", testpath, "-c", "config.json" }

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
