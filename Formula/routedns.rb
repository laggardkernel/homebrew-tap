require "language/go"

class Routedns < Formula
  desc "DNS stub resolver, proxy and router with support for DoT, DoH, DoQ, and DTLS"
  homepage "https://github.com/folbricht/routedns"
  # url ""
  # sha256 ""
  head "https://github.com/folbricht/routedns.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"

    path = buildpath/"src/github.com/folbricht/routedns"
    path.install Dir["*"]
    # Language::Go.stage_deps resources, buildpath/"src"

    cd path/"cmd/routedns" do
      system "go", "build", "-o", bin/"routedns"
      prefix.install_metafiles

      # cp example-config into share
      share_dst = "#{prefix}/share/routedns"
      mkdir_p share_dst
      cp_r "example-config", share_dst
    end

    (buildpath/"config.toml").write <<~EOS
      # Google DoT
      [resolvers.google8]
      address = "8.8.8.8:853"
      protocol = "dot"

      [resolvers.google4]
      address = "8.8.4.4:853"
      protocol = "dot"

      [groups.google-dot]
      # type = "cache"
      # type = "round-robin"
      type = "fail-rotate"
      # type = "response-collape"
      resolvers = ["google8", "google4"]

      [listeners.local-udp]
      address = "127.0.0.1:5300"
      protocol = "udp"
      resolver = "google-dot"

      [listeners.local-tcp]
      address = "127.0.0.1:5300"
      protocol = "tcp"
      resolver = "google-dot"
    EOS

    config_path = etc/"routedns"
    mkdir_p config_path
    Dir.glob(["config.toml"]).each do |dst|
      dst_default = config_path/"#{dst}.default"
      rm dst_default if dst_default.exist?
      config_path.install dst
    end
  end

  test do
    system bin/"routedns", "-h"
  end

  def caveats; <<~EOS
    routedns listens on localhost (127.0.0.1), port 5300 in default conf file.

    Homebrew services are run as LaunchAgents by current user.
    To make chinadns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "routedns /usr/local/etc/routedns/config.toml"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/routedns</string>
          <string>#{etc}/routedns/config.toml</string>
        </array>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end
end
