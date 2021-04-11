require "language/go"

class Mosdns < Formula
  desc "Flexible forwarding DNS client"
  homepage "https://github.com/IrineSistiana/mosdns"
  version "1.7.2"
  license "GPL-3.0"

  livecheck do
    url "https://github.com/IrineSistiana/mosdns/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  bottle :unneeded

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if !build.without?("prebuilt")
    on_macos do
      url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-darwin-amd64.zip"
      sha256 "63799df6e8bd35a5e44b736e5ff66d75e73dd7f40475ed65424513973908bd8d"
    end
    on_linux do
      url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-amd64.zip"
    end
  else
    # http downloading is quick than git cloning
    url "https://github.com/IrineSistiana/mosdns/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/IrineSistiana/mosdns.git", tag: "v#{version}"

    depends_on "go" => :build
    depends_on "upx" => :build
  end

  head do
    # version: HEAD
    # url "https://github.com/IrineSistiana/mosdns/archive/refs/heads/main.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/IrineSistiana/mosdns.git", branch: "main"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "upx" => :build
  end

  # TODO: drop one cidr list?
  resource "china_ip_list" do
    url "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
  end

  resource "geoip2-cn-txt" do
    url "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt"
  end

  def install
    # version_str = "#{version}".start_with?("HEAD") ? "#{version}" : "v#{version}"

    if build.without?("prebuilt") || build.head?
      version_str = "#{version}".start_with?("HEAD") ? "#{version}" : "v#{version}"

      # Warning: setting GOPATH under CWD, may cause pkg failed to build
      buildpath_parent = File.dirname(buildpath)
      if buildpath_parent.start_with? "mosdns"
        ENV["GOPATH"] = "#{buildpath_parent}/go"
      else
        ENV["GOPATH"] = "#{buildpath}/.brew_home/go"
      end
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-build"

      # Mimic release.py
      mkdir_p "#{buildpath}/release"
      cd "#{buildpath}/release"
      system "go run ../ -gen config.yaml"
      system "go", "build", "-ldflags", "-s -w -X main.version=#{version_str}", "-trimpath", "-o", "mosdns", "../"
      system "upx -9 -q mosdns"
      cp "../README.md", "."
      cp "../LICENSE", "."
    end

    bin.install "mosdns"
    prefix.install_metafiles

    # rename config-template.yaml, seems unneeded >= 1.5.0
    mv "config-template.yaml", "config.yaml" if File.file?("config-template.yaml")
    share_dst = "#{prefix}/share/mosdns"
    mkdir_p "#{share_dst}"
    cp_r Dir["*.list"], "#{share_dst}/"
    cp_r Dir["*.yaml"], "#{share_dst}/"
    resource("china_ip_list").stage {
      cp "china_ip_list.txt", "#{share_dst}/"
    }
    resource("geoip2-cn-txt").stage {
      cp "CN-ip-cidr.txt", "#{share_dst}/"
    }

    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp
    # Conf installation borrowed from php.rb
    Dir.chdir("#{etc_temp}") do
      config_path = etc/"mosdns"
      Dir.glob(["*.yaml", "*.list", "*.txt"]).each do |dst|
        dst_default = config_path/"#{dst}.default"
        rm dst_default if dst_default.exist?
        config_path.install dst
      end
    end
    rm_rf "#{etc_temp}"
  end

  def post_install
    (var/"log/mosdns").mkpath
    chmod 0755, var/"log/mosdns"
  end

  test do
    system "#{bin}/mosdns", "-v"
  end

  def caveats; <<~EOS
    Homebrew services are run as LaunchAgents by current user.
    To make mosdns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    After using `sudo` with `brew services`. Run `brew fix-perm`.
  EOS
  end

  plist_options :manual => "mosdns -dir /usr/local/etc/mosdns -c /usr/local/etc/mosdns/config.yaml"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>KeepAlive</key>
        <dict>
            <key>SuccessfulExit</key>
            <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/mosdns</string>
            <string>-dir</string>
            <string>#{etc}/mosdns</string>
            <string>-c</string>
            <string>#{etc}/mosdns/config.yaml</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>StandardErrorPath</key>
        <string>#{var}/log/mosdns/mosdns.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/mosdns/mosdns.log</string>
    </dict>
    </plist>
  EOS
  end
end
