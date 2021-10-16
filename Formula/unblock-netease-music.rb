class UnblockNeteaseMusic < Formula
  desc "Revive unavailable songs for Netease Cloud Music"
  # homepage "https://github.com/nondanee/UnblockNeteaseMusic"
  version "0.26.1"
  # homepage "https://github.com/1715173329/UnblockNeteaseMusic"
  homepage "https://github.com/UnblockNeteaseMusic/server"
  url "https://github.com/UnblockNeteaseMusic/server/archive/refs/tags/v#{version}.tar.gz"
  # sha256 ""
  license "MIT"

  livecheck do
    # Pre-release support
    url "https://github.com/UnblockNeteaseMusic/server/releases"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[-]?[^"]*)["' >]}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
    # url :stable
    # strategy :github_latest
  end

  bottle :unneeded

  depends_on "node"
  # depends_on "yarn" => :build # install dep and run with DEVELOPMENT=true
  # Default yarn cache dir: #{buildpath}/.brew_home/Library/Caches/Yarn/v6

  def install
    inreplace "src/provider/select.js" do |s|
      s.gsub! "5 * 1e3", "8 * 1e3"
    end
    # Starting 0.27, precompiled entries are included to avoid yarn install
    if File.exist? "precompiled/app.js"
      inreplace "precompiled/app.js" do |s|
        s.gsub! "5 * 1e3", "8 * 1e3"
      end
    end

    mkdir_p buildpath/"bin"
    (buildpath/"bin/unblock-nm").write <<~EOS
    #!/bin/sh
    #{HOMEBREW_PREFIX}/opt/node/bin/node "#{opt_prefix}/app.js" "$@"
    EOS

    (buildpath/"bin/unblock-nm-bridge").write <<~EOS
    #!/bin/sh
    #{HOMEBREW_PREFIX}/opt/node/bin/node "#{opt_prefix}/bridge.js" "$@"
    EOS

    bin.install
    prefix.install Dir.glob("*")
    prefix.install_metafiles

  end

  def post_install
    ("#{var}/log/unblock-netease-music").mkpath
    chmod 0755, "#{var}/log/unblock-netease-music"
  end

  def caveats
    <<~EOS
    Fork on https://github.com/UnblockNeteaseMusic/server
    Service listens on 16300, 16301 by default. Options are written in

      #{plist_path}

    Current provider order set in service: kuwo
    EOS
  end

  plist_options manual: "unblock-nm --help"

  # TODO: ANSI escape color code is not filtered when dumping log to file.
  #  Switch json format log temporarily.
  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>EnvironmentVariables</key>
          <dict>
            <key>ENABLE_LOCAL_VIP</key>
            <string>true</string>
            <key>JSON_LOG</key>
            <string>true</string>
          </dict>
          <key>ProgramArguments</key>
            <array>
              <string>#{HOMEBREW_PREFIX}/opt/node/bin/node</string>
              <string>#{opt_prefix}/app.js</string>
              <string>-a</string>
              <string>127.0.0.1</string>
              <string>-p</string>
              <string>16300:16301</string>
              <string>-f</string>
              <string>223.252.199.66</string>
              <string>-e</string>
              <string>https://music.163.com</string>
              <string>-o</string>
              <string>kuwo</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
            <key>StandardOutPath</key>
            <string>#{var}/log/#{name}/access.log</string>
            <key>StandardErrorPath</key>
            <string>#{var}/log/#{name}/access.log</string>
            <key>WorkingDirectory</key>
            <string>#{opt_prefix}</string>
          </dict>
      </plist>
    EOS
  end

  test do
    system "#{HOMEBREW_PREFIX}/opt/bin/node", "#{opt_prefix}/app.js", "-v"
  end
end

# IPs
# - old: 223.252.199.66
# - new: 59.111.160.195, 59.111.160.197
# Match: https://github.com/nondanee/UnblockNeteaseMusic/issues/372#issuecomment-583751043
