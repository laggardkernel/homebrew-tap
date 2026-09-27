class EasytierBin < Formula
  desc "Decentralized P2P mesh VPN"
  homepage "https://github.com/EasyTier/EasyTier"
  version "2.6.4"
  license "LGPL-3.0-only"

  os_name = OS.mac? ? "macos" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "aarch64" : "x86_64"
  basename = "easytier-#{os_name}-#{cpu_arch}-v#{version}.zip"
  url "https://github.com/EasyTier/EasyTier/releases/download/v#{version}/#{basename}"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    bin.install %w[easytier-core easytier-cli easytier-web easytier-web-embed]
    prefix.install_metafiles

    (bin/"easytier-core-env").write <<~EOS
      #!/bin/sh
      if [ "$1" = "--env-file" ]; then
        env_file=$2
        shift 2
        set -a
        [ -f "$env_file" ] && . "$env_file"
        set +a
      fi
      exec "#{opt_bin}/easytier-core" "$@"
    EOS

    generate_completions_from_executable(bin/"easytier-cli", "gen-autocomplete")
    generate_completions_from_executable(bin/"easytier-core", "--gen-autocomplete")

    (etc/"easytier").mkpath
    (etc/"easytier/config.toml.example").atomic_write <<~EOF
      # Copy to config.toml and fill network_name / network_secret.
      # dhcp creates a utun; socks5_proxy is a localhost SOCKS5 like Tailscale.
      instance_name = "default"
      dhcp = true
      socks5_proxy = "socks5://127.0.0.1:1080"
      rpc_portal = "127.0.0.1:15888"

      [network_identity]
      network_name = "change-me"
      network_secret = "change-me"

      [[peer]]
      uri = "tcp://public.easytier.cn:11010"
    EOF
    (etc/"easytier/.env.example").atomic_write <<~EOS
      # Copy to .env. brew services sources this via --env-file.
      # ET_CONFIG_DIR and ET_CONFIG_FILE are optional; comment out unused ones.
      HOME=#{var}/lib/easytier
      ET_CONFIG_DIR=#{etc}/easytier
      ET_CONFIG_FILE=#{etc}/easytier/config.toml
      ET_FILE_LOG_LEVEL=error
      ET_FILE_LOG_DIR=#{var}/log/easytier
      # ET_CONFIG_SERVER=tcp://et-web.console.easytier.net:22020/etk_…
    EOS
  end

  post_install_steps do
    mkdir_p "lib/easytier", base: :var
    mkdir_p "log/easytier", base: :var
  end

  def caveats
    <<~EOS
      Homebrew services are LaunchAgents as the current user.
      Creating a utun and installing routes needs a privileged service,
      same as MacPorts tailscaled under /Library/LaunchDaemons:

        sudo brew services start #{name}

      If you use `sudo brew services`, run `brew fix-perm` afterwards
      to restore file permissions.

      brew services runs easytier-core-env --env-file
        #{etc}/easytier/.env
      and starts easytier-core with no extra flags.
      Example: #{etc}/easytier/.env.example

      Set ET_FILE_LOG_DIR there. ET_CONFIG_DIR and ET_CONFIG_FILE
      are optional. With ET_CONFIG_DIR, the daemon watches
      #{etc}/easytier/*.toml.

      Example:
        #{etc}/easytier/config.toml.example

      Docs: https://easytier.cn/en/
    EOS
  end

  service do
    require_root true
    run [opt_bin/"easytier-core-env", "--env-file", etc/"easytier/.env"]
    keep_alive true
    working_dir var/"lib/easytier"
    log_path var/"log/easytier/run.log"
    error_log_path var/"log/easytier/run.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/easytier-core --version")
    assert_match version.to_s, shell_output("#{bin}/easytier-core-env --env-file /dev/null --version")
    assert_match version.to_s, shell_output("#{bin}/easytier-cli --version")
    assert_match version.to_s, shell_output("#{bin}/easytier-web --version")
    assert_match version.to_s, shell_output("#{bin}/easytier-web-embed --version")
  end
end
