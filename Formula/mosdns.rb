class Mosdns < Formula
  desc "Flexible forwarding DNS client"
  homepage "https://github.com/IrineSistiana/mosdns"
  version "1.8.6"
  license "GPL-3.0"

  head do
    # version: HEAD
    # url "https://github.com/IrineSistiana/mosdns/archive/refs/heads/main.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/IrineSistiana/mosdns.git", branch: "main"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "upx" => :build
  end

  bottle :unneeded

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/IrineSistiana/mosdns/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/IrineSistiana/mosdns.git", tag: "v#{version}"

    depends_on "go" => :build
    depends_on "upx" => :build
  elsif OS.mac?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-darwin-amd64.zip"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-amd64.zip"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-32-bit?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-arm-7.zip"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-64-bit?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-arm64.zip"
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
      version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"

      buildpath_parent = File.dirname(buildpath)
      ENV["GOPATH"] = if File.basename(buildpath_parent).start_with? "mosdns"
        "#{buildpath_parent}/go"
      else
        "#{buildpath}/.brew_home/go"
      end
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-build"

      # Mimic release.py
      mkdir_p "#{buildpath}/release"
      cd "#{buildpath}/release"
      system "go", "run", "../", "-gen", "config.yaml"
      system "go", "build", "-ldflags", "-s -w -X main.version=#{version_str}", "-trimpath", "-o", "mosdns", "../"
      system "upx", "-9", "-q", "mosdns"
      cp "../README.md", "."
      cp "../LICENSE", "."
    end

    bin.install "mosdns"
    prefix.install_metafiles

    # rename config-template.yaml, seems unneeded >= 1.5.0
    mv "config-template.yaml", "config.yaml" if File.file?("config-template.yaml")
    share_dst = "#{share}/mosdns"
    mkdir_p share_dst.to_s
    cp_r Dir["*.list"], "#{share_dst}/"
    cp_r Dir["*.yaml"], "#{share_dst}/"
    resource("china_ip_list").stage do
      cp "china_ip_list.txt", "#{share_dst}/"
    end
    resource("geoip2-cn-txt").stage do
      cp "CN-ip-cidr.txt", "#{share_dst}/"
    end

    etc_temp = "#{buildpath}/etc_temp"
    cp_r "#{share_dst}/.", etc_temp
    # Conf installation borrowed from php.rb
    Dir.chdir(etc_temp.to_s) do
      config_path = etc/"mosdns"
      Dir.glob(["*.yaml"]).each do |dst|
        dst_default = config_path/"#{dst}.default"
        rm dst_default if dst_default.exist?
        config_path.install dst
      end
      # mv Dir.glob(["*.list", "*.txt"]), config_path, force: true
      Dir.glob(["*.list", "*.txt"]).each do |dst|
        dst_default = config_path/"#{dst}.default"
        rm dst_default if dst_default.exist?
        rm config_path/dst.to_s if (config_path/dst.to_s).exist?
        config_path.install dst
      end
    end
    rm_rf etc_temp.to_s
  end

  def post_install
    (var/"log/mosdns").mkpath
    chmod 0755, var/"log/mosdns"
  end

  def caveats
    <<~EOS
      Homebrew services are run as LaunchAgents by current user.
      To make mosdns service work on privileged port, like port 53,
      you need to run it as a "global" daemon in /Library/LaunchAgents.

        sudo cp -f #{plist_path} /Library/LaunchAgents/

      After using `sudo` with `brew services`. Run `brew fix-perm`.
    EOS
  end

  plist_options manual: "mosdns -dir #{HOMEBREW_PREFIX}/etc/mosdns -c /usr/local/etc/mosdns/config.yaml"
  def plist
    <<~EOS
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

  test do
    system "#{bin}/mosdns", "-v"
  end
end
