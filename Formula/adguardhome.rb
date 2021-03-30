require "language/node"
require "language/go"

class Adguardhome < Formula
  desc "Network-wide ads & trackers blocking DNS server"
  homepage "https://github.com/AdguardTeam/AdGuardHome"
  version "0.106.0-b.1"
  url "https://github.com/AdguardTeam/AdGuardHome/archive/refs/tags/v#{version}.tar.gz"
  sha256 "644bc45873630f931f9d6ab4c72fddfc73ea064d13e390e2ecc99f8141489734"
  license "GPL-3.0"

  # conflicts_with "adguardhome-bin", :because => "same package"

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "yarn" => :build

  def install
    # Warning: don't put GOPATH in CWD, failed to build cause packr err raised
    buildpath_parent = File.dirname(buildpath)
    ENV["GOPATH"] = "#{buildpath_parent}/go"
    ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-build"
    ENV["PATH"] = "#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/opt/node/libexec/bin"
    # TODO: compile cache folder from node
    # - v8-compile-cache-501
    # - /private/tmp//private/tmp/yarn--
    ENV["V8_COMPILE_CACHE_CACHE_DIR"] = "#{buildpath_parent}/v8-compile-cache"  # not work

    # Use Makefile, steps split on purpose for debugging this formula
    # system "make", "js-deps", "NPM=#{HOMEBREW_PREFIX}/opt/node/libexec/bin/npm"
    system "make", "deps"

    # https://github.com/AdguardTeam/AdGuardHome/issues/2807
    Dir["#{ENV["GOPATH"]}/pkg/mod/github.com/*/dnsproxy@*/proxy/server_udp.go"].each do |dst|
      # inreplace = cp + mod + mv
      chmod 0666, dst
      chmod 0777, File.dirname(dst)
      inreplace dst do |s|
        s.gsub! "err = proxyutil.UDPSetOptions(udpListen)", "err = nil"
      end
      # system is called in subprocess, seems not current user, read err
      # system "/usr/bin/sed", "-i", "''", "s/err = proxyutil.UDPSetOptions(udpListen)/err = nil/", dst
    end

    # CHANNEL: release, beta, development(default)
    # VERSION: vmajor.minor.patch
    system "make", "quick-build", "CHANNEL=release", "VERSION=v#{version}"
    # equivalent
    # system "make", "js-build"
    # system "make", "go-build"

    bin.install "AdGuardHome"
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

    which conflicts the launchd profile provided by this formula.

    Caveat: use `sudo` if AdGuardHome listens at a privileged port.
    If the service is started with `sudo` `brew services`. Run `brew fix-perm`
    to fix the broken file perms.
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
