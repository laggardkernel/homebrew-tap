class MosdnsAT4 < Formula
  desc "Flexible forwarding DNS client"
  homepage "https://github.com/IrineSistiana/mosdns"
  version "4.5.3"
  license "GPL-3.0"
  revision 3

  livecheck do
    skip "4.x versions are no longer developed"
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/IrineSistiana/mosdns/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/IrineSistiana/mosdns.git", tag: "v#{version}"

    depends_on "go" => :build
  else
    os_name = OS.mac? ? "darwin" : "linux"
    if Hardware::CPU.intel?
      cpu_arch = "amd64"
    elsif Hardware::CPU.ppc64le?
      cpu_arch = "ppc64le"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      cpu_arch = "arm64"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
      cpu_arch = "arm-7"
    end
    basename = "mosdns-#{os_name}-#{cpu_arch}.zip"
    url "https://github.com/IrineSistiana/mosdns/releases/download/v#{version}/#{basename}"
  end

  resource "geoip.dat" do
    url "https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/geoip.dat"
  end

  resource "geosite.dat" do
    url "https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
  end

  def install
    # version_str = "#{version}".start_with?("HEAD") ? "#{version}" : "v#{version}"

    if build.without?("prebuilt") || build.head?
      version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"

      # Mimic release.py
      mkdir_p "#{buildpath}/release"
      cd "#{buildpath}/release"
      system "go", "run", "../", "-gen", "config-v4.yaml"
      system "go", "build", "-ldflags", "-s -w -X main.version=#{version_str}", "-trimpath", "-o", "mosdns", "../"

      cp "../README.md", "."
      cp "../LICENSE", "."
    end

    bin.install "mosdns" => "mosdns4"
    prefix.install_metafiles

    mv "config.yaml", "config-v4.yaml"
    share_dst = "#{share}/mosdns@4"
    mkdir_p share_dst.to_s
    cp_r Dir["*.yaml"], "#{share_dst}/"

    etc_temp = "#{buildpath}/etc_temp"
    mkdir_p "#{etc_temp}/builtin-data"
    cp_r "#{share_dst}/.", etc_temp
    ["geoip.dat", "geosite.dat"].each do |f|
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
    (var/"log/mosdns@4").mkpath
    chmod 0755, var/"log/mosdns@4"

    Dir.chdir(etc/"mosdns/builtin-data") do
      system(
        prefix/"bin/mosdns4",
        "v2dat",
        "unpack-domain",
        "-o", ".",
        "geosite.dat:apple-cn,google-cn,gfw"
      )
      system(
        prefix/"bin/mosdns4",
        "v2dat",
        "unpack-ip",
        "-o", ".",
        "geoip.dat:cn"
      )
    end
  end

  def caveats
    <<~EOS
      Check https://github.com/Loyalsoldier/v2ray-rules-dat for how to use
        the v2ray rules dat: geosite.dat and geoip.dat.
      Homebrew services are run as LaunchAgents by current user.
      To make mosdns service work on privileged port, like port 53,
      you need to run it as a "global" daemon in /Library/LaunchAgents.

        sudo cp -f #{launchd_service_path} /Library/LaunchAgents/

      If you prefer using `sudo brew services`. Run `brew fix-perm` after it
      to fix the ruined file permissions.
    EOS
  end

  service do
    run [opt_bin/"mosdns4", "start", "-d", etc/"mosdns", "-c", etc/"mosdns/config-v4.yaml"]
    # keep_alive { succesful_exit: true }
    log_path var/"log/mosdns@4/mosdns.log"
    error_log_path var/"log/mosdns@4/mosdns.log"
  end

  test do
    system bin/"mosdns4", "version"
  end
end
