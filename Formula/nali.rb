class Nali < Formula
  desc "Offline tool for querying IP geographic information and CDN provider"
  homepage "https://github.com/zu1k/nali"
  version "0.3.7-2"
  license "MIT"

  head do
    # version: HEAD
    # url "https://github.com/zu1k/nali/archive/refs/heads/master.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/zu1k/nali.git"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/zu1k/nali/archive/refs/tags/#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/zu1k/nali.git", tag: "#{version}"

    depends_on "go" => :build
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-darwin-amd64-#{version}.gz"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-darwin-arm64-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-linux-amd64-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-linux-386-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && RUBY_PLATFORM.to_s.include?("armv6")
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-linux-armv6-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-linux-armv7-#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/zu1k/nali/releases/download/#{version}/nali-linux-armv8-#{version}.gz"
  end

  def install
    if build.without?("prebuilt") || build.head?
      # Warning: putting GOPATH in CWD may fail to build cause packr err raised
      buildpath_parent = File.dirname(buildpath)
      ENV["GOPATH"] = if File.basename(buildpath_parent).start_with? "nali"
        "#{buildpath_parent}/go"
      else
        "#{buildpath}/.brew_home/go"
      end
      # Default GOCACHE: $HOMEBREW_CACHE/go_cache
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"

      system "go", "build", "-o", "nali"
    end
    bin.install Dir["nali*"][0] => "nali"
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      zu1k/nali has support for different geoip databases. Related
      environment varialbles are:

      - NALI_DB, default chunzhen
      - NALI_DB_HOME, default ~/.nali

      Check the project's README for detail. https://github.com/zu1k/nali
    EOS
  end

  test do
    system "#{bin}/nali", "-h"
  end
end
