require "language/node"

class Adguardhome < Formula
  desc "Network-wide ads & trackers blocking DNS server"
  homepage "https://github.com/AdguardTeam/AdGuardHome"
  version "0.108.0-b.1"
  license "GPL-3.0"

  livecheck do
    # `brew style --fix` keeps converting it to wrong value :stable
    url "https://github.com/AdguardTeam/AdGuardHome/releases/"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+(?:[-_].+?)?)["' >]}i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      # E.g. 0.107.0 ==> 0.107.0-b.17
      page.scan(regex).flatten.first
      # page.scan(regex).flatten.uniq
    end
  end

  head do
    # version: HEAD
    url "https://github.com/AdguardTeam/AdGuardHome/archive/refs/heads/master.tar.gz"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    # url "https://github.com/AdguardTeam/AdGuardHome.git"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "upx" => :build
    depends_on "yarn" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  # sha256: skipped, too complicated
  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/AdguardTeam/AdGuardHome/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/AdguardTeam/AdGuardHome.git", tag: "v#{version}"

    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "yarn" => :build
    depends_on "upx" => :build
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_darwin_arm64.zip"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_darwin_amd64.zip"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_amd64.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_386.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && RUBY_PLATFORM.to_s.include?("armv6")
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_armv6.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_armv7.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_arm64.tar.gz"
  end

  def install
    if build.without?("prebuilt") || build.head?
      # CHANNEL: release, beta, development(default)
      # VERSION: v{major.minor.patch}, or HEAD-<commit_id>
      channel = if build.head?
        "development"
      elsif version.to_s.include?("beta") || version.to_s.include?("b") \
          || version.to_s.include?("pre")
        "beta"
      else
        "release"
      end
      version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"

      # Warning: setting GOPATH under CWD may cause pkg failed to build cause packr exc
      # Only encounter once during writing the formula, later resolved
      buildpath_parent = File.dirname(buildpath)
      ENV["GOPATH"] = if File.basename(buildpath_parent).start_with? "adguardhome"
        "#{buildpath_parent}/go"
      else
        "#{buildpath}/.brew_home/go"
      end
      # Default GOCACHE: $HOMEBREW_CACHE/go_cache
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"
      ENV["PATH"] = "#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/opt/node/libexec/bin"
      ENV["PATH"] = "#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/lib/node_modules/npm/bin"
      # BUG: Formula["node"] doen't ensure version installed
      # ENV.append_path "PATH", Formula["node"].bin.to_s
      # ENV.append_path "PATH", "#{Formula["node"].libexec}/bin"
      # TODO: compile cache folder from node
      # - v8-compile-cache-501
      # - /private/tmp//private/tmp/yarn--
      ENV["V8_COMPILE_CACHE_CACHE_DIR"] = "#{buildpath_parent}/v8-compile-cache" # not work

      # Use Makefile, steps split on purpose for debugging this formula
      # system "make", "js-deps", "NPM=#{HOMEBREW_PREFIX}/opt/node/libexec/bin/npm"
      system "make", "js-deps"
      system "make", "js-build"

      system "make", "go-deps"

      system "make", "CHANNEL=#{channel}", "VERSION=#{version_str}", "go-build"
      system "upx", "-9", "-q", "AdGuardHome"
    end

    # TODO: lowercase?
    bin.install "AdGuardHome"
    # All that README/LICENSE/NOTES/CHANGELOG stuff? Use "metafiles"
    prefix.install_metafiles
    mkdir_p etc/"adguardhome"
  end

  def post_install
    (var/"log/adguardhome").mkpath
    chmod 0755, var/"log/adguardhome"
  end

  def caveats
    <<~EOS
      https://github.com/AdguardTeam/AdGuardHome/wiki/Getting-Started.
      Recommend saving config in #{etc}/adguardhome dir.

        sudo AdGuardHome -w #{etc}/adguardhome

      AdGuardHome executable could control the launchd service by itself.

        sudo AdGuardHome -w #{etc}/adguardhome -s start
        sudo AdGuardHome -w #{etc}/adguardhome -s stop

      Launchd profile provided by this formula serves the same purpose.

      Caveat:
      1. Use `sudo` if AdGuardHome listens at a privileged port.
      2. If the service is started with `sudo brew services`. Run `brew fix-perm`
         to fix the broken file perms. Not needed for `sudo AdGuardHome -s`.
    EOS
  end

  plist_options manual: "sudo AdGuardHome -w #{HOMEBREW_PREFIX}/etc/adguardhome"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/AdGuardHome</string>
          <string>-w</string>
          <string>#{etc}/adguardhome</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{etc}/adguardhome</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/adguardhome/adguardhome.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/adguardhome/adguardhome.log</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
      </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/AdGuardHome", "--version"
  end
end
