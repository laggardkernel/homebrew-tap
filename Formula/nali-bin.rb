class NaliBin < Formula
  desc "Offline tool for querying IP geographic information and CDN provider"
  homepage "https://github.com/zu1k/nali"
  version "0.8.1"
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
    url "https://github.com/zu1k/nali/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/zu1k/nali.git", tag: "v#{version}"

    depends_on "go" => :build
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-darwin-amd64-v#{version}.gz"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-darwin-arm64-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-linux-amd64-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-linux-386-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && RUBY_PLATFORM.to_s.include?("armv6")
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-linux-armv6-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-linux-armv7-v#{version}.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/zu1k/nali/releases/download/v#{version}/nali-linux-armv8-v#{version}.gz"
  end

  def install
    if build.without?("prebuilt") || build.head?
      system "go", "build", "-trimpath", "-o", "nali"
    end
    bin.install Dir["nali*"][0] => "nali"
    chmod 0755, bin/"nali"
    prefix.install_metafiles

    generate_completions_from_executable(bin/"nali", "completion", base_name: "nali")
  end

  def caveats
    <<~EOS
      zu1k/nali has support for different geoip databases. Related
      environment varialbles are:

      - NALI_HOME, defaults to ~/.nali
      - NALI_DB_HOME, deprecates since 0.4
      - NALI_DB_IP4, db used for IPv4 query
      - NALI_DB_IP6, db used for IPv6 query

      Check the project's README for detail. https://github.com/zu1k/nali
    EOS
  end

  test do
    system bin/"nali", "-h"
  end
end
