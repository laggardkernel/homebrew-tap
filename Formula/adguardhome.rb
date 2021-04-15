require "language/node"
require "language/go"

class Adguardhome < Formula
  desc "Network-wide ads & trackers blocking DNS server"
  homepage "https://github.com/AdguardTeam/AdGuardHome"
  version "0.106.0-b.2"
  license "GPL-3.0"

  bottle :unneeded

  # conflicts_with "adguardhome-bin", :because => "same package"

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  # sha256: skipped, too complicated
  if !build.without?("prebuilt")
    if OS.mac?
      url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_darwin_amd64.zip"
    elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_amd64.tar.gz"
    elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
      url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_386.tar.gz"
    elsif OS.linux? && Hardware::CPU.arm? && "#{RUBY_PLATFORM}".include?("armv6")
      url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_armv6.tar.gz"
    elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
      url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_armv7.tar.gz"
    elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_linux_arm64.tar.gz"
    end
  else
    # http downloading is quick than git cloning
    url "https://github.com/AdguardTeam/AdGuardHome/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/AdguardTeam/AdGuardHome.git", tag: "v#{version}"

    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "yarn" => :build
    depends_on "upx" => :build
  end

  head do
    # version: HEAD
    # url "https://github.com/AdguardTeam/AdGuardHome/archive/refs/heads/master.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/AdguardTeam/AdGuardHome.git"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "yarn" => :build
    depends_on "upx" => :build
  end

  def install
    if build.without? "prebuilt" or build.head?
      # CHANNEL: release, beta, development(default)
      # VERSION: v{major.minor.patch}, or HEAD-<commit_id>
      if build.head?
        channel = "development"
      elsif "#{version}".include? "beta" or "#{version}".include? "b" \
          or "#{version}".include? "pre"
        channel = "beta"
      else
        channel = "release"
      end
      version_str = "#{version}".start_with?("HEAD") ? "#{version}" : "v#{version}"

      # Warning: setting GOPATH under CWD, may cause pkg failed to build
      # packr exc
      buildpath_parent = File.dirname(buildpath)
      if buildpath_parent.start_with? "mosdns"
        ENV["GOPATH"] = "#{buildpath_parent}/go"
      else
        ENV["GOPATH"] = "#{buildpath}/.brew_home/go"
      end
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-build"
      ENV["PATH"] = "#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/opt/node/libexec/bin"
      # TODO: compile cache folder from node
      # - v8-compile-cache-501
      # - /private/tmp//private/tmp/yarn--
      ENV["V8_COMPILE_CACHE_CACHE_DIR"] = "#{buildpath_parent}/v8-compile-cache"  # not work

      # Use Makefile, steps split on purpose for debugging this formula
      # system "make", "js-deps", "NPM=#{HOMEBREW_PREFIX}/opt/node/libexec/bin/npm"
      system "make", "js-deps"
      system "make", "js-build"

      system "make", "go-deps"

      if OS.mac?
        # https://github.com/AdguardTeam/AdGuardHome/issues/2807
        # Dir["#{ENV["GOPATH"]}/pkg/mod/github.com/*/dnsproxy@*/proxy/server_udp.go"].each do |dst|
        #   # inreplace = cp + mod + mv
        #   chmod 0666, dst
        #   chmod 0777, File.dirname(dst)
        #   inreplace dst do |s|
        #     s.gsub! "err = proxyutil.UDPSetOptions(udpListen)", "err = nil"
        #   end
        #   # system is called in subprocess, seems not current user, read err
        #   # system "/usr/bin/sed", "-i", "''", "s/err = proxyutil.UDPSetOptions(udpListen)/err = nil/", dst
        # end
        Dir["#{ENV["GOPATH"]}/pkg/mod/github.com/*/dnsproxy@*/proxyutil/udp_unix.go"].each do |dst|
          # Skip setting control msg for ipv4 udp conn, which impact listening addr
          # err4 := ipv4.NewPacketConn(c).SetControlMessage(ipv4.FlagDst|ipv4.FlagInterface, true)
          chmod 0666, dst
          chmod 0777, File.dirname(dst)
          inreplace dst do |s|
            s.gsub! /err4\s*:=\s*ipv4.NewPacketConn.+SetControlMessage.+/, "var err4 *int"
          end
        end
      end

      system "make", "go-build", "CHANNEL=#{channel}", "VERSION=#{version_str}"
      system "upx -9 -q AdGuardHome"
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

  def caveats; <<~EOS
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

  # #{etc} is not supported here
  plist_options :manual => "sudo AdGuardHome -w /usr/local/etc/adguardhome"

  def plist; <<~EOS
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
