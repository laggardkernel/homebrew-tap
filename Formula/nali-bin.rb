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

  conflicts_with "nali", because: "they are variants of the same package"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/zu1k/nali/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/zu1k/nali.git", tag: "v#{version}"

    depends_on "go" => :build
  else
    os_name = OS.mac? ? "darwin" : "linux"
    if Hardware::CPU.intel?
      if OS.linux? && Hardware::CPU.is_32_bit?
        cpu_arch = "386"
      else
        cpu_arch = "amd64"
      end
    elsif Hardware::CPU.arm?
      if OS.mac?
        cpu_arch = "arm64"
      elsif OS.linux? && RUBY_PLATFORM.to_s.include?("armv6")
        cpu_arch = "armv6"
      elsif OS.linux? && Hardware::CPU.is_32_bit?
        cpu_arch = "armv7"
      elsif OS.linux?
        cpu_arch = "armv8"
      end
    end
    basename = "nali-#{os_name}-#{cpu_arch}-v#{version}.gz"
    url "https://github.com/zu1k/nali/releases/download/v#{version}/#{basename}"
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
