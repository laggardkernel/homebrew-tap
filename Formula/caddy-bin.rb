class CaddyBin < Formula
  desc "Powerful, enterprise-ready, open source web server with automatic HTTPS"
  homepage "https://caddyserver.com/"
  version "2.11.1"
  license "Apache-2.0"

  if OS.mac?
    os_name = "mac"
    cpu_arch = Hardware::CPU.intel? ? "amd64": "arm64"
  else
    os_name = "linux"
    if Hardware::CPU.ppc64le?
      cpu_arch = "ppc64le"
    elsif Hardware::CPU.arm?
      cpu_arch = "arm64"
    else
      cpu_arch = "amd64"
    end
  end
  basename = "caddy_#{version}_#{os_name}_#{cpu_arch}.tar.gz"
  url "https://github.com/caddyserver/caddy/releases/download/v#{version}/#{basename}"

  def install
    bin.install "caddy"

    generate_completions_from_executable(bin/"caddy", "completion")
    system bin/"caddy", "manpage", "--directory", buildpath/"man"
    man8.install Dir[buildpath/"man/*.8"]
  end

  def post_install
    (var/"lib/caddy").mkpath
    chmod 0755, var/"lib/caddy"
    (var/"log/caddy").mkpath
    chmod 0755, var/"log/caddy"

    unless (etc/"caddy/Caddyfile").exist?
      (etc/"caddy").mkpath
      (etc/"caddy/Caddyfile").write("")
    end
  end

  def caveats
    <<~EOS
      When running the provided service, caddy's data dir will be set as
        `#{HOMEBREW_PREFIX}/var/lib/caddy`
        instead of the default location found at https://caddyserver.com/docs/conventions#data-directory
    EOS
  end

  service do
    run [opt_bin/"caddy", "run", "--config", etc/"caddy/Caddyfile"]
    keep_alive true
    # error_log_path var/"log/caddy.log"
    # log_path var/"log/caddy.log"
    environment_variables(
      XDG_DATA_HOME: "#{HOMEBREW_PREFIX}/var/lib",
      HOME:          "#{HOMEBREW_PREFIX}/var/lib",
    )
  end

  test do
    port1 = free_port
    port2 = free_port

    (testpath/"Caddyfile").write <<~EOS
      {
        admin 127.0.0.1:#{port1}
      }

      http://127.0.0.1:#{port2} {
        respond "Hello, Caddy!"
      }
    EOS

    fork do
      exec bin/"caddy", "run", "--config", testpath/"Caddyfile"
    end
    sleep 2

    assert_match "\":#{port2}\"",
      shell_output("curl -s http://127.0.0.1:#{port1}/config/apps/http/servers/srv0/listen/0")
    assert_match "Hello, Caddy!", shell_output("curl -s http://127.0.0.1:#{port2}")

    assert_match version.to_s, shell_output("#{bin}/caddy version")
  end
end
