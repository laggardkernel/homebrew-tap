class RoamgateBin < Formula
  desc "Web and PWA client for Herdr"
  homepage "https://roamgate.dev/"
  version "0.7.10"
  license "MIT"

  depends_on :macos

  cpu_arch = Hardware::CPU.arm? ? "arm64" : "x64"
  basename = "roamgate-v#{version}-darwin-#{cpu_arch}.tar.xz"
  url "https://github.com/powerfooI/roamgate/releases/download/v#{version}/#{basename}"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    binary = File.exist?("roamgate") ? "roamgate" : Dir["**/roamgate"].first
    bin.install binary => "roamgate"
    pkgshare.install "VERSION" if File.exist?("VERSION")

    (bin/"roamgate-server").write <<~EOS
      #!/bin/sh
      set -a
      [ -f "${HOME}/.config/roamgate/.env-server" ] && . "${HOME}/.config/roamgate/.env-server"
      set +a
      exec "#{opt_bin}/roamgate" "$@"
    EOS
  end

  def post_install_steps
    (var/"lib/roamgate").mkpath
    chmod 0755, var/"lib/roamgate"
  end

  def caveats
    <<~EOS
      Data & configuration directory:
        ~/.config/roamgate

      Executables:
        roamgate        - Native upstream CLI binary
        roamgate-server - Wrapper script that sources ~/.config/roamgate/.env-server
                          before executing roamgate

      Start service:
        brew services start #{name}

      Herdr server:
        roamgate requires a running Herdr server (https://herdr.dev).

      Configuration:
        By default, roamgate listens on http://127.0.0.1:8787.
        For available options and environment variables, see:
          https://github.com/powerfooI/roamgate/blob/main/docs/DEPLOYMENT.md#basic-runtime-configuration
    EOS
  end

  service do
    run [opt_bin/"roamgate-server"]
    keep_alive true
    working_dir var/"lib/roamgate"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/roamgate -V").chomp
    assert_match version.to_s, shell_output("#{bin}/roamgate-server -V").chomp

    # Verify wrapper sources .env-server
    (testpath/".config/roamgate").mkpath
    port = free_port
    (testpath/".config/roamgate/.env-server").write "PORT=#{port}\n"

    pid = spawn({ "HOME" => testpath.to_s }, bin/"roamgate-server")
    sleep 2
    assert_match "HTTP/1.1 200 OK", shell_output("curl -sI http://127.0.0.1:#{port}/")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
