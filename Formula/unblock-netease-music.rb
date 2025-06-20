class UnblockNeteaseMusic < Formula
  desc "Revive unavailable songs for Netease Cloud Music"
  # homepage "https://github.com/nondanee/UnblockNeteaseMusic"
  # homepage "https://github.com/1715173329/UnblockNeteaseMusic"
  homepage "https://github.com/UnblockNeteaseMusic/server"
  # rubocop: disable all
  version "0.27.10"
  url "https://github.com/UnblockNeteaseMusic/server/archive/refs/tags/v#{version}.tar.gz"
  # rubocop: enable all
  license "MIT"

  livecheck do
    # Pre-release support
    url "https://github.com/UnblockNeteaseMusic/server/releases"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+-?[^"]*)["' >]}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
    # strategy :github_latest
  end

  # version: HEAD
  head "https://github.com/UnblockNeteaseMusic/server/archive/refs/heads/enhanced.tar.gz"
  # Git repo is not cloned into a sub-folder. version, HEAD-1234567
  # url "https://github.com/UnblockNeteaseMusic/server.git", branch "enhanced"

  # yarn is depended by DEVELOPMENT=true
  # Use yarn from corepack since yarn 1.22.21. https://github.com/yarnpkg/yarn/issues/9015
  depends_on "corepack" => :build
  depends_on "node"
  # Default yarn cache dir:
  # - ~~#{Dir.home}/Library/Caches/Yarn/v6~~
  # - #{Dir.home}/.yarn/berry

  def install
    inreplace "src/provider/select.js" do |s|
      s.gsub! "5 * 1e3", "8 * 1e3"
    end
    # Starting 0.27, precompiled entries are included to avoid yarn install
    if File.exist? "precompiled/app.js"
      inreplace "precompiled/app.js" do |s|
        # s.gsub! "5 * 1e3", "8 * 1e3"
        # # 0.27.0-b9
        # s.gsub! "< 5000", "< 8000"
        # # 0.27.0-rc.4
        # s.gsub! "< 5 * 1000", "< 8 * 1000"
        # # 0.27.0
        # s.gsub! "<5e3", "<8e3"
        # 0.27.1
        s.gsub! "5e3>", "8e3>"
      end
    end

    server_path = libexec/"lib/node_modules/@unblockneteasemusic/server"
    mkdir_p server_path.to_s

    sources = Dir.entries(buildpath)
    sources -= [".", "..", ".brew_home"]
    cp_r sources, server_path.to_s

    (libexec/"bin/unblock-nm").write <<~EOS
      #!/bin/bash
      CMD=("#{Formula["node"].opt_prefix}/bin/node")
      if [[ -n "$DEVELOPMENT" ]]; then
        CMD+=("-r" "#{server_path}/.pnp.cjs")
      fi
      CMD+=("#{server_path}/app.js")
      "${CMD[@]}" "$@"
    EOS
    (libexec/"bin/unblock-nm-bridge").write <<~EOS
      #!/bin/bash
      CMD=("#{Formula["node"].opt_prefix}/bin/node")
      if [[ -n "$DEVELOPMENT" ]]; then
        CMD+=("-r" "#{server_path}/.pnp.cjs")
      fi
      CMD+=("#{server_path}/bridge.js")
      "${CMD[@]}" "$@"
    EOS
    chmod 0755, libexec/"bin/unblock-nm"
    chmod 0755, libexec/"bin/unblock-nm-bridge"
    bin.mkdir
    ["unblock-nm", "unblock-nm-bridge"].each do |v|
      ln_sf (libexec/"bin/#{v}").relative_path_from(bin.to_s), "#{bin}/#{v}"
    end
    prefix.install_metafiles

    # Enable development support for 0.27+
    Dir.chdir(server_path.to_s) do
      ENV["COREPACK_ENABLE_DOWNLOAD_PROMPT"] = "0"
      # Switch to yarn v3/berry/stable since 0.27.0-rc.6. Global cache is disabled by default.
      # https://yarnpkg.com/cli/set/version#details
      # system "yarn", "set", "version", "berry"
      system "yarn", "--version"
      system "yarn", "config", "set", "enableGlobalCache", "false"
      system "yarn", "install"
      system "yarn", "build" # precompiled/ in repo may not be up-to-date
    end
  end

  def post_install
    (var/"log/unblock-netease-music").mkpath
    chmod 0755, var/"log/unblock-netease-music"
  end

  def caveats
    <<~EOS
      https://github.com/UnblockNeteaseMusic/server
      Service listens on 16300, 16301 by default. Options are written in

        #{launchd_service_path}

      Current provider order set in service: pyncmd, kuwo
    EOS
  end

  # TODO: ANSI escape color code is not filtered when dumping log to file.
  #  Switch json format log temporarily.
  service do
    environment_variables ENABLE_LOCAL_VIP: "svip", BLOCK_ADS: "true", DISABLE_UPGRADE_CHECK: "true",
DEVELOPMENT: "true", JSON_LOG: "true"
    run [opt_bin/"unblock-nm", "-a", "127.0.0.1", "-p", "16300:16301", "-e", "https://music.163.com", "-f",
         "59.111.160.195", "-o", "pyncmd", "kuwo"]
    # keep_alive { succesful_exit: true }
    log_path var/"log/unblock-netease-music/access.log"
    error_log_path var/"log/unblock-netease-music/access.log"
  end

  test do
    system "#{HOMEBREW_PREFIX}/opt/bin/node", "#{opt_prefix}/app.js", "-v"
  end
end

# IPs
# - old: 223.252.199.66
# - new: 59.111.160.195, 59.111.160.197
# Match: https://github.com/nondanee/UnblockNeteaseMusic/issues/372#issuecomment-583751043
# 0.27.x, UnblockNeteaseMusic/server
# minimal Node.js version 12. https://github.com/UnblockNeteaseMusic/server/discussions/254
