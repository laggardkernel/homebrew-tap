class NavidromeBin < Formula
  desc "Modern Music Server and Streamer compatible with Subsonic/Airsonic"
  homepage "https://www.navidrome.org/"
  # Check build dependency versions requirement before bumping up the version:
  # - https://github.com/navidrome/navidrome/blob/master/go.mod
  # - https://github.com/navidrome/navidrome/blob/master/.nvmrc
  version "0.60.3"
  license "GPL-3.0"

  livecheck do
    url :stable
    strategy :github_releases
  end

  head do
    # version: HEAD
    url "https://github.com/navidrome/navidrome/archive/refs/heads/master.tar.gz"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    # url "https://github.com/navidrome/navidrome.git"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "pkg-config" => :build
    depends_on "taglib" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  conflicts_with "navidrome", because: "they are variants of the same package"

  # sha256: skipped, too complicated
  if build.without?("prebuilt") || OS.mac?
    # http downloading is quick than git cloning
    url "https://github.com/navidrome/navidrome/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/navidrome/navidrome.git", tag: "v#{version}"

    # The setup is very strict, and the steps below only work with these versions (enforced in the Makefile)
    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "pkg-config" => :build
    depends_on "taglib" => :build
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_linux_amd64.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_linux_386.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && RUBY_PLATFORM.to_s.include?("armv6")
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_linux_armv6.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_linux_armv7.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_linux_arm64.tar.gz"
  end

  def install
    if build.without?("prebuilt") || build.head? || OS.mac?
      if version.to_s.start_with?("HEAD")
        version_str, sha_str = version.to_s.split("-")
      else
        version_str = "v#{version}"
        sha_str = "source_archive"
      end

      # Delete taglib hardcode introduced in 0.53
      # https://github.com/navidrome/navidrome/pull/3217
      f = "scanner/metadata/taglib/taglib_wrapper.go"
      if File.read(f).include?("#cgo darwin LDFLAGS")
        inreplace f, /^#cgo darwin LDFLAGS.*$/, ""
      end

      system "make", "setup"
      # https://github.com/navidrome/navidrome/issues/1512
      system "make", "buildjs"
      # If not git repo as source, export '-buildvcs=false'
      system "go", "build", "-trimpath", "-o", "navidrome",
        "-ldflags",
        "-X github.com/navidrome/navidrome/consts.gitTag=#{version_str} -X github.com/navidrome/navidrome/consts.gitSha=#{sha_str}",
        "-buildvcs=false"
    end

    # *std_go_args install and rename executable may raise "empty installation" error
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
    keep_alive successful_exit: true
    working_dir var/"log/navidrome"
    log_path var/"log/navidrome/navidrome.log"
    error_log_path var/"log/navidrome/navidrome.log"
  end

  test do
    assert_equal "#{version} (source_archive)", shell_output("#{bin}/navidrome --version").chomp
    port = free_port
    pid = fork do
      exec bin/"navidrome", "--port", port.to_s
    end
    sleep 15
    assert_equal ".", shell_output("curl http://localhost:#{port}/ping")
  ensure
    Process.kill "TERM", pid
    Process.wait pid
  end
end
