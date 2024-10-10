class Mosdns < Formula
  desc "Flexible forwarding DNS client"
  homepage "https://github.com/IrineSistiana/mosdns"
  version "5.3.3"
  license "GPL-3.0"

  head do
    # version: HEAD
    # url "https://github.com/IrineSistiana/mosdns/archive/refs/heads/main.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/IrineSistiana/mosdns.git", branch: "main"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/IrineSistiana/mosdns/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/IrineSistiana/mosdns.git", tag: "v#{version}"

    depends_on "go" => :build
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-darwin-arm64.zip"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-darwin-amd64.zip"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-amd64.zip"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-32-bit?)
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-arm-7.zip"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-64-bit?)
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/mosdns-linux-arm64.zip"
  end

  # resource "china_ip_list.txt" do
  #   url "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
  # end
  resource "CN-ip-cidr.txt" do
    url "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt"
  end

  resource "geoip.dat" do
    url "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
  end

  resource "geosite.dat" do
    url "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
  end

  def install
    # version_str = "#{version}".start_with?("HEAD") ? "#{version}" : "v#{version}"

    if build.without?("prebuilt") || build.head?
      version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"

      # Mimic release.py
      mkdir_p "#{buildpath}/release"
      cd "#{buildpath}/release"
      system "go", "run", "../", "-gen", "config.yaml"
      system "go", "build", "-ldflags", "-s -w -X main.version=#{version_str}", "-trimpath", "-o", "mosdns", "../"

      cp "../README.md", "."
      cp "../LICENSE", "."
    end

    bin.install "mosdns"
    prefix.install_metafiles

    share_dst = "#{share}/mosdns"
    mkdir_p share_dst.to_s
    cp_r Dir["*.yaml"], "#{share_dst}/"

    etc_temp = "#{buildpath}/etc_temp"
    mkdir_p "#{etc_temp}/builtin-data"
    cp_r "#{share_dst}/.", etc_temp
    ["CN-ip-cidr.txt", "geoip.dat", "geosite.dat"].each do |f|
      resource(f).stage do
        cp f, "#{etc_temp}/builtin-data/"
      end
    end
    # Conf installation borrowed from php.rb
    Dir.chdir(etc_temp.to_s) do
      config_path = etc/"mosdns"
      mkdir_p "#{config_path}/builtin-data"
      Dir.glob(["*.yaml"]).each do |f|
        dst = config_path/"#{f}.default"
        rm dst if dst.exist?
        config_path.install f
      end
      # mv Dir.glob(["*.dat"]), config_path, force: true
      Dir.glob(["builtin-data/*.dat", "builtin-data/*.txt"]).each do |f|
        dst = config_path/"#{f}.default"
        rm dst if dst.exist?
        rm config_path/f.to_s if (config_path/f.to_s).exist?
        config_path.install f => f.to_s
      end
    end
    rm_r(etc_temp.to_s)
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

        sudo cp -f #{launchd_service_path} /Library/LaunchAgents/

      If you prefer using `sudo brew services`. Run `brew fix-perm` after it
      to fix the ruined file permissions.
    EOS
  end

  service do
    run [opt_bin/"mosdns", "start", "-d", etc/"mosdns", "-c", etc/"mosdns/config.yaml"]
    # keep_alive { succesful_exit: true }
    log_path var/"log/mosdns/mosdns.log"
    error_log_path var/"log/mosdns/mosdns.log"
  end

  test do
    system bin/"mosdns", "version"
  end
end
