class HellogrokBin < Formula
  desc "Local proxy for Grok Build custom model channels"
  homepage "https://github.com/hellowind777/hellogrok"
  version "0.1.17"
  license "MIT"

  os_name = OS.mac? ? "darwin" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "amd64"
  basename = "hellogrok-#{os_name}-#{cpu_arch}"
  url "https://github.com/hellowind777/hellogrok/releases/download/v#{version}/#{basename}"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    binary = Dir["hellogrok-*"][0]
    chmod 0755, binary
    bin.install binary => "hellogrok"
  end

  def caveats
    <<~EOS
      hellogrok is a Grok Build channel proxy. It needs a readable
      ~/.grok/config.toml (or $GROK_HOME/config.toml) with at least one
      custom model URL.

      Start the proxy:
        hellogrok start
        brew services start #{name}

      Built-in login autostart writes
      ~/Library/LaunchAgents/com.hellogrok.proxy.plist on macOS.
      Use either brew services or `hellogrok autostart`, not both.

      After an unclean exit:
        hellogrok restore

      Runtime data lives in ~/.hellogrok.
    EOS
  end

  service do
    run [opt_bin/"hellogrok", "start"]
    keep_alive true
    # log_path var/"log/hellogrok.log"
    # error_log_path var/"log/hellogrok.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hellogrok version")
    assert_match "hellogrok #{version}", shell_output("#{bin}/hellogrok help")
  end
end
