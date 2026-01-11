class SingBoxRef1ndDevel < Formula
  desc "Universal proxy platform"
  homepage "https://github.com/reF1nd/sing-box"
  version "1.13.0-beta.2-reF1nd"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://github.com/reF1nd/sing-box/tags"
    regex(%r{href="/.+/releases/tag/v?(\d+(?:\.\d+)+-[^"]+-reF1nd(\.\d+)?)"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq
    end
  end

  conflicts_with "sing-box", "sing-box-ref1nd"

  # using `:homebrew_curl` to work around audit failure from TLS 1.3-only homepage
  url "https://github.com/reF1nd/sing-box/archive/refs/tags/v#{version}.tar.gz"
  # Git repo is not cloned into a sub-folder
  # url "https://github.com/reF1nd/sing-box.git", tag: "v#{version}"
  depends_on "go" => :build

  resource "config.json" do
    url "https://raw.githubusercontent.com/SagerNet/sing-box/main/release/config/config.json"
  end

  def install
    # https://github.com/reF1nd/sing-box/blob/reF1nd-dev/.github/workflows/build.yml
    ldflags = "-s -buildid= -X github.com/sagernet/sing-box/constant.Version=#{version} -checklinkname=0"
    tags = %w[
      with_gvisor
      with_quic
      with_dhcp
      with_wireguard
      with_utls
      with_acme
      with_clash_api
      with_tailscale
      with_ccm
      with_ocm
      badlinkname
      tfogo_checklinkname0
      with_naive_outbound
    ]

    system "go", "build", *std_go_args(ldflags:, tags: tags.join(","), output: bin/"sing-box"), "./cmd/sing-box"
    # go build put the binary into bin directly
    # bin.install "sing-box"
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
