class CliProxyApiBin < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  version "6.7.41"
  license "MIT"

  os_name = OS.mac? ? "darwin" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "amd64"
  basename = ["CLIProxyAPI", version, os_name, cpu_arch].join("_")
  url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v#{version}/#{basename}.tar.gz"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    bin.install "cli-proxy-api"
    (etc/"cli-proxy-api/").install "config.example.yaml"
  end

  def post_install
    (var/"lib/cli-proxy-api").mkpath
    chmod 0755, var/"lib/cli-proxy-api"
    (var/"log/cli-proxy-api").mkpath
    chmod 0755, var/"log/cli-proxy-api"
  end

  def caveats
    <<~EOS
      The cli-proxy-api brew service uses '--config #{HOMEBREW_PREFIX}/etc/cli-proxy-api/config.yaml',
      and runs under '#{HOMEBREW_PREFIX}/var/lib/cli-proxy-api'.
      It's recommended to store state files, auth files under the var directory
      thru configuration.

      For how to use cli-proxy-api, check for the document
        https://help.router-for.me/configuration/basic.html
    EOS
  end

  service do
    run [opt_bin/"cli-proxy-api", "--config", etc/"cli-proxy-api/config.yaml"]
    keep_alive successful_exit: true
    working_dir var/"lib/cli-proxy-api"
  end

  test do
    require "pty"
    PTY.spawn(bin/"cli-proxy-api", "-login", "-no-browser") do |r, _w, pid|
      sleep 5
      Process.kill "TERM", pid
      assert_match "accounts.google.com", r.read_nonblock(1024)
    end
  end
end
