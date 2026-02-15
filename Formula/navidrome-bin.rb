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
  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/navidrome/navidrome/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/navidrome/navidrome.git", tag: "v#{version}"

    # The setup is very strict, and the steps below only work with these versions (enforced in the Makefile)
    depends_on "go" => :build
    depends_on "node" => :build
    depends_on "pkg-config" => :build
    depends_on "taglib" => :build
  else
    os_name = OS.mac? ? "darwin" : "linux"
    if Hardware::CPU.intel?
      cpu_arch = Hardware::CPU.is_64_bit? ? "amd64" : "386"
    elsif Hardware::CPU.arm?
      cpu_arch = Hardware::CPU.is_64_bit? ? "arm64" : "armv7"
    end
    name_middle = [os_name, cpu_arch].reject(&:empty?).join("_")
    url "https://github.com/navidrome/navidrome/releases/download/v#{version}/navidrome_#{version}_#{name_middle}.tar.gz"
  end

  def install
    if build.without?("prebuilt") || build.head?
      # Workaround to avoid patchelf corruption when cgo is required
      if OS.linux? && Hardware::CPU.arch == :arm64
        ENV["CGO_ENABLED"] = "1"
        ENV["GO_EXTLINK_ENABLED"] = "1"
        ENV.append "GOFLAGS", "-buildmode=pie"
      end

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

      ldflags = %W[
        -s -w
        -X github.com/navidrome/navidrome/consts.gitTag=#{version_str}
        -X github.com/navidrome/navidrome/consts.gitSha=#{sha_str}
      ]
      system "make", "setup"
      # https://github.com/navidrome/navidrome/issues/1512
      system "make", "buildjs"
      # If not git repo as source, export '-buildvcs=false'
      system "go", "build", "-trimpath",
        "-o", "navidrome",
        "-ldflags", ldflags.join(" "),
        "-tags", "netgo",
        "-buildvcs=false"
    end

    # *std_go_args install and rename executable may raise "empty installation" error
    bin.install "navidrome"
    generate_completions_from_executable(bin/"navidrome", shell_parameter_format: :cobra)

    share_dst = "#{share}/navidrome"
    mkdir_p share_dst.to_s
    config_dst = etc/"navidrome"
    music_folder = "/Users/#{ENV["USER"]}/Music"
    (buildpath/"config.toml").write <<~EOS
      # vim: ft=toml fdm=marker foldlevel=0 sw=2 ts=2 sts=2 et
      # https://www.navidrome.org/docs/usage/configuration-options/
      MusicFolder = "#{music_folder}"
      DataFolder = "#{config_dst}/data"
      ScanSchedule = "@every 15m"
    EOS
    # Save a copy of default config into share
    cp "config.toml", "#{share_dst}/"
    # Install/move conf into etc
    ["config.toml"].each do |dst|
      dst_default = config_dst/"#{dst}.default"
      rm dst_default if dst_default.exist?
      config_dst.install dst
    end
  end

  def post_install
    (var/"cache/navidrome").mkpath
    chmod 0755, var/"cache/navidrome"
    (var/"lib/navidrome").mkpath
    chmod 0755, var/"lib/navidrome"
    (var/"log/navidrome").mkpath
    chmod 0755, var/"log/navidrome"
  end

  def caveats
    <<~EOS
      Check "#{etc}/navidrome/config.toml" before running it with "brew services".

      Navidrome listens at port 4533 by default.

      Remember to install ffmpeg in your system, a requirement for Navidrome
      to work properly. You may find the latest static build for your platform here:
      https://johnvansickle.com/ffmpeg/
    EOS
  end

  service do
    environment_variables PATH: "#{std_service_path_env}:/opt/local/bin:/opt/local/sbin"
    run [opt_bin/"navidrome", "-c", etc/"navidrome/config.toml"]
    keep_alive successful_exit: true
    working_dir var/"log/navidrome"
    log_path var/"log/navidrome/navidrome.log"
    error_log_path var/"log/navidrome/navidrome.log"
  end

  test do
    assert_equal "#{version} (source_archive)", shell_output("#{bin}/navidrome --version").chomp
    port = free_port
    pid = spawn bin/"navidrome", "--port", port.to_s
    sleep 20
    sleep 100 if OS.mac? && Hardware::CPU.intel?
    assert_equal ".", shell_output("curl http://localhost:#{port}/ping")
  ensure
    Process.kill "KILL", pid
    Process.wait pid
  end
end
