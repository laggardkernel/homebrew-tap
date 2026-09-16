class CodegServer < Formula
  desc "Collaborative multi-agent AI coding workspace (server daemon and web UI)"
  homepage "https://github.com/xintaofei/codeg"
  version "0.30.10"
  license "Apache-2.0"

  os_name = OS.mac? ? "darwin" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "x64"
  basename = "codeg-server-#{os_name}-#{cpu_arch}.tar.gz"
  url "https://github.com/xintaofei/codeg/releases/download/v#{version}/#{basename}"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    libexec.install "codeg-server", "codeg-mcp"
    pkgshare.install "web"

    # Codeg doesn't bundle Node.js/npm; it relies on the ambient toolchain (Node >= 22).
    # For npm-based ACP agents (Claude Code, etc.), codeg normally falls back to
    # ~/.codeg/npm-global on EACCES. Forcing NPM_CONFIG_PREFIX ensures all agent
    # adapters install into this isolated location deterministically.
    (bin/"codeg-server").write <<~EOS
      #!/bin/sh
      export CODEG_STATIC_DIR="${CODEG_STATIC_DIR:-"#{opt_pkgshare}/web"}" \
        NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-"${HOME}/.codeg/npm-global"}" \
        PATH="${HOME}/.codeg/npm-global/bin:${PATH}"
      exec "#{opt_libexec}/codeg-server" "$@"
    EOS

    bin.install_symlink libexec/"codeg-mcp"
  end

  def post_install_steps
    (var/"lib/codeg-server").mkpath
    chmod 0755, var/"lib/codeg-server"
  end

  def caveats
    <<~EOS
      Data directory:
        ~/Library/Application Support/codeg

      Start service:
        brew services start #{name}

      Node.js runtime & ACP agents:
        codeg-server requires external Node.js (>= 22.0.0) and npm to run
        npm-based ACP agents (e.g. Claude Code, Codex).
        Agent packages and binaries are isolated deterministically in:
          ~/.codeg/npm-global (via NPM_CONFIG_PREFIX)

      Customization:
        By default, codeg-server listens on http://127.0.0.1:3080.
        Environment variables: CODEG_HOST, CODEG_PORT, CODEG_TOKEN, CODEG_DATA_DIR
    EOS
  end

  service do
    run [opt_bin/"codeg-server"]
    keep_alive true
    working_dir var/"lib/codeg-server"
    environment_variables PATH: "/opt/local/bin:#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/codeg-server -V").chomp

    port = free_port
    pid = spawn({ "CODEG_PORT" => port.to_s, "CODEG_DATA_DIR" => testpath.to_s }, bin/"codeg-server")
    sleep 3
    assert_match "HTTP/1.1 200 OK", shell_output("curl -sI http://127.0.0.1:#{port}/")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
