class Filebrowser < Formula
  desc "Provides a file managing interface within a specified directory"
  homepage "https://filebrowser.org"
  version "2.22.4"
  # sha256
  license "MIT"

  head do
    # version: HEAD
    # url "https://github.com/filebrowser/filebrowser/archive/refs/heads/master.zip"
    # Git repo is not cloned into a sub-folder.
    url "https://github.com/filebrowser/filebrowser.git"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "node" => :build
    if !(OS.mac? && Hardware::CPU.arm?)
      depends_on "upx" => :build
    end
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/filebrowser/filebrowser/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/filebrowser/filebrowser.git", tag: "v#{version}"

    depends_on "go" => :build
    depends_on "node" => :build
    if !(OS.mac? && Hardware::CPU.arm?)
      depends_on "upx" => :build
    end
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/filebrowser/filebrowser/releases/download/v#{version}/darwin-amd64-filebrowser.tar.gz"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/filebrowser/filebrowser/releases/download/v#{version}/darwin-arm64-filebrowser.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/filebrowser/filebrowser/releases/download/v#{version}/linux-amd64-filebrowser.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && !Hardware::CPU.is_64_bit?
    url "https://github.com/filebrowser/filebrowser/releases/download/v#{version}/linux-armv6-filebrowser.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/filebrowser/filebrowser/releases/download/v#{version}/linux-arm64-filebrowser.tar.gz"
  end

  def install
    if build.without?("prebuilt") || build.head?
      # File Browser v2.15.0/73ccbe91. HEAD-sha -> HEAD
      version_str = version.to_s.start_with?("HEAD") ? "HEAD" : version.to_s

      buildpath_parent = File.dirname(buildpath)
      if File.basename(buildpath_parent).start_with? "filebrowser"
        ENV["GOPATH"] = "#{buildpath_parent}/go"
        ENV["NPM_CONFIG_CACHE"] = "#{buildpath_parent}/npm"
        commit_sha = ""
      else
        ENV["GOPATH"] = "#{buildpath}/.brew_home/go"
        ENV["NPM_CONFIG_CACHE"] = "#{buildpath}/.brew_home/npm"
        commit_sha = `git rev-parse --short HEAD`
      end
      # Default GOCACHE: $HOMEBREW_CACHE/go_cache
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"
      ENV["PATH"] = "#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/opt/node/libexec/bin"
      ENV["PATH"] = "#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/lib/node_modules/npm/bin"
      # BUG: Formula["node"] doen't ensure version installed
      # ENV.append_path "PATH", Formula["node"].bin.to_s
      # ENV.append_path "PATH", "#{Formula["node"].libexec}/bin"

      # Makefile and .goreleaser.yml
      # Separate fronend, backend bulding for easy debugging
      system "make", "build-frontend"

      # Version, commit_sha in Makefile are set in different format as in release
      # Set them manually.
      inreplace "cmd/version.go" do |s|
        s.gsub! "File Browser v", "File Browser " if version_str == "HEAD" || version_str.start_with?("v")
        if commit_sha == ""
          s.gsub!(/^(.+fmt\.Println.+version\.Version).*?$/, '\1)') # single quote
        end
      end
      go_build_ldflags = "-s -w" \
        + " -X github.com/filebrowser/filebrowser/v2/version.Version=#{version_str}" \
        + " -X github.com/filebrowser/filebrowser/v2/version.CommitSHA=#{commit_sha}"
      go_build_cmd = "GO111MODULE=on CGO_ENABLED=0 go build" \
        + " -ldflags '#{go_build_ldflags}'"
      system go_build_cmd
      if !(OS.mac? && Hardware::CPU.arm?)
        system "upx", "-9", "-q", "filebrowser"
      end
    end

    bin.install Dir.glob("filebrowser*")[0] => "filebrowser"

    share_dst = "#{share}/filebrowser"
    mkdir_p share_dst.to_s
    config_path = etc/"filebrowser"

    # https://github.com/filebrowser/filebrowser/blob/master/.docker.json
    root_dir = ENV["USER"]
    root_dir = "/Users/#{root_dir}"
    (buildpath/".filebrowser.json").write <<~EOS
      {
        "port": 8080,
        "baseURL": "",
        "address": "localhost",
        "log": "stdout",
        "database": "#{config_path}/filebrowser.db",
        "root": "#{root_dir}"
      }
    EOS

    # Save a copy of default config into share
    cp ".filebrowser.json", "#{share_dst}/"

    # Install/move conf into etc
    [".filebrowser.json"].each do |dst|
      dst_default = config_path/"#{dst}.default"
      rm dst_default if dst_default.exist?
      config_path.install dst
    end
  end

  def post_install
    (var/"log/filebrowser").mkpath
    chmod 0755, var/"log/filebrowser"
  end

  def caveats
    <<~EOS
      By default, filebrowser listens on localhost:8080 with auth
        username: admin
        password: admin

      Check detail usage at https://filebrowser.org/
    EOS
  end

  plist_options manual: "filebrowser -c #{HOMEBREW_PREFIX}/etc/filebrowser/.filebrowser.json"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/filebrowser</string>
          <string>-c</string>
          <string>#{etc}/filebrowser/.filebrowser.json</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{etc}/filebrowser</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/filebrowser/filebrowser.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/filebrowser/filebrowser.log</string>
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
    system "#{bin}/filebrowser", "version"
  end
end
