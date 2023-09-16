class Navidrome < Formula
  desc "Modern Music Server and Streamer compatible with Subsonic/Airsonic"
  homepage "https://www.navidrome.org/"
  # Check build dependency versions requirement before bumping up the version:
  # - https://github.com/navidrome/navidrome/blob/master/go.mod
  # - https://github.com/navidrome/navidrome/blob/master/.nvmrc
  version "0.49.3"
  license "GPL-3.0"

  livecheck do
    url "https://github.com/navidrome/navidrome/releases"
    strategy :github_release
  end

  head do
    # version: HEAD
    url "https://github.com/navidrome/navidrome/archive/refs/heads/master.tar.gz"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    # url "https://github.com/navidrome/navidrome.git"

    # Warn: build.head doesn't work under "class"
    depends_on "go@1.19" => :build
    depends_on "node@16" => :build
    depends_on "taglib" => :build
    depends_on "upx" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  # sha256: skipped, too complicated
  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/navidrome/navidrome/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/navidrome/navidrome.git", tag: "v#{version}"

    # The setup is very strict, and the steps below only work with these versions (enforced in the Makefile)
    depends_on "go@1.19" => :build
    depends_on "node@16" => :build
    depends_on "taglib" => :build
    depends_on "upx" => :build
  elsif OS.mac?
    # elsif OS.mac? && Hardware::CPU.intel?
    # TODO: no Mac arm64 prebuilt yet
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_macOS_x86_64.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_Linux_x86_64.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_Linux_i386.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && RUBY_PLATFORM.to_s.include?("armv6")
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_Linux_armv6.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_Linux_armv7.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_Linux_armv64.tar.gz"
  end

  def install
    # version_str = "#{version}".start_with?("HEAD") ? "#{version}" : "v#{version}"

    if build.without?("prebuilt") || build.head? # || (OS.mac? && Hardware::CPU.arm?)
      version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"

      buildpath_parent = File.dirname(buildpath)
      if File.basename(buildpath_parent).start_with? "navidrome"
        ENV["GOPATH"] = "#{buildpath_parent}/go"
        ENV["NPM_CONFIG_CACHE"] = "#{buildpath_parent}/npm"
      else
        ENV["GOPATH"] = "#{buildpath}/.brew_home/go"
        ENV["NPM_CONFIG_CACHE"] = "#{buildpath}/.brew_home/npm"
      end
      # Default GOCACHE: $HOMEBREW_CACHE/go_cache
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"
      # BUG: Formula["node"] doen't ensure version installed
      # ENV.append_path "PATH", Formula["node@16"].bin.to_s
      # If not git repo as source, export '-buildvcs=false'
      ENV["GOFLAGS"] = "-buildvcs=false"

      system "make", "setup"
      # https://github.com/navidrome/navidrome/issues/1512
      system "make", "buildjs"
      system "make", "build"
      system "upx", "-9", "-q", "navidrome"
    end

    bin.install "navidrome"
    prefix.install_metafiles

    share_dst = "#{share}/navidrome"
    mkdir_p share_dst.to_s
    config_dst = etc/"navidrome"
    music_folder = "/Users/#{ENV["USER"]}/Music"
    (buildpath/"navidrome.toml").write <<~EOS
      # vim: ft=toml fdm=marker foldlevel=0 sw=2 ts=2 sts=2 et
      # https://www.navidrome.org/docs/usage/configuration-options/
      MusicFolder = "#{music_folder}"
      DataFolder = "#{config_dst}/data"
      ScanSchedule = "@every 15m"
    EOS
    # Save a copy of default config into share
    cp "navidrome.toml", "#{share_dst}/"
    # Install/move conf into etc
    ["navidrome.toml"].each do |dst|
      dst_default = config_dst/"#{dst}.default"
      rm dst_default if dst_default.exist?
      config_dst.install dst
    end
  end

  def post_install
    (var/"log/navidrome").mkpath
    chmod 0755, var/"log/navidrome"
  end

  def caveats
    <<~EOS
      Check "#{etc}/navidrome/navidrome.toml" before running it with "brew services".

      Navidrome listens at port 4533 by default.

      Remember to install ffmpeg in your system, a requirement for Navidrome
      to work properly. You may find the latest static build for your platform here:
      https://johnvansickle.com/ffmpeg/
    EOS
  end

  service do
    run [opt_bin/"navidrome", "-c", etc/"navidrome/navidrome.toml"]
    # keep_alive { succesful_exit: true }
    working_dir var/"log/navidrome"
    log_path var/"log/navidrome/navidrome.log"
    error_log_path var/"log/navidrome/navidrome.log"
  end

  test do
    system "#{bin}/navidrome", "--help"
  end
end
