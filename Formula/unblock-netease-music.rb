class UnblockNeteaseMusic < Formula
  desc "Revive unavailable songs for Netease Cloud Music"
  # homepage "https://github.com/nondanee/UnblockNeteaseMusic"
  # homepage "https://github.com/1715173329/UnblockNeteaseMusic"
  homepage "https://github.com/UnblockNeteaseMusic/server"
  version "0.27.1"
  url "https://github.com/UnblockNeteaseMusic/server/archive/refs/tags/v#{version}.tar.gz"
  # sha256 ""
  license "MIT"

  livecheck do
    # Pre-release support
    url "https://github.com/UnblockNeteaseMusic/server/releases"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+-?[^"]*)["' >]}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
    # url :stable
    # strategy :github_latest
  end

  # yarn is depended for DEVELOPMENT=true
  depends_on "yarn" => :build
  depends_on "node"
  # Default yarn cache dir: #{buildpath}/.brew_home/Library/Caches/Yarn/v6

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

    mkdir_p buildpath/"bin"
    (buildpath/"bin/unblock-nm").write <<~EOS
      #!/bin/bash
      #{HOMEBREW_PREFIX}/opt/node/bin/node -r "#{prefix}/.pnp.cjs" "#{prefix}/app.js" "$@"
    EOS

    (buildpath/"bin/unblock-nm-bridge").write <<~EOS
      #!/bin/bash
      #{HOMEBREW_PREFIX}/opt/node/bin/node -r "#{prefix}/.pnp.cjs" "#{prefix}/bridge.js" "$@"
    EOS

    bin.install
    prefix.install Dir.glob("*")
    prefix.install_metafiles

    # Enable development support for 0.27+
    Dir.chdir(prefix.to_s) do
      # Switch to yarn 2 since 0.27.0-rc.6. Global cache is disabled by default.
      system "yarn", "set", "version", "berry"
      system "yarn", "config", "set", "enableGlobalCache", "false"
      system "yarn", "install"
    end
  end

  def post_install
    "#{var}/log/unblock-netease-music".mkpath
    chmod 0755, "#{var}/log/unblock-netease-music"
  end

  def caveats
    <<~EOS
      https://github.com/UnblockNeteaseMusic/server
      Service listens on 16300, 16301 by default. Options are written in

        #{plist_path}

      Current provider order set in service: pyncmd, kuwo
    EOS
  end

  # TODO: ANSI escape color code is not filtered when dumping log to file.
  #  Switch json format log temporarily.
  service do
    environment_variables DEVELOPMENT: "true", ENABLE_LOCAL_VIP: "true", JSON_LOG: "true", BLOCK_ADS: "true", DISABLE_UPGRADE_CHECK: "true"
    run [opt_bin/"unblock-nm", "-a", "127.0.0.1", "-p", "16300:16301", "-e", "https://music.163.com", "-f", "59.111.160.195", "-o", "pyncmd", "kuwo"]
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
