class Dnspeep < Formula
  desc "Spy on the DNS queries your computer is making"
  homepage "https://github.com/jvns/dnspeep"
  version "0.1.3"
  license "MIT"

  head do
    # version: HEAD
    # url "https://github.com/jvns/dnspeep/archive/refs/heads/main.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/jvns/dnspeep.git", branch: "main"

    # Warn: build.head doesn't work under "class"
    depends_on "rust" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/jvns/dnspeep/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/jvns/dnspeep.git", tag: "v#{version}"

    depends_on "rust" => :build
  elsif OS.mac?
    url "https://github.com/jvns/dnspeep/releases/download/v#{version}/dnspeep-macos.tar.gz"
  elsif OS.linux
    url "https://github.com/jvns/dnspeep/releases/download/v#{version}/dnspeep-linux.tar.gz"
  end

  def install
    if build.without?("prebuilt") || build.head?
      # cargo build --release, and cd into target/release
      system "cargo", "install", *std_cargo_args
    else
      bin.install "dnspeep"
    end
    prefix.install_metafiles
  end

  test do
    system bin/"dnspeep", "--help"
  end
end
