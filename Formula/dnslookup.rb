class Dnslookup < Formula
  desc "Simple command-line utility to make DNS lookups using any protocol"
  homepage "https://github.com/ameshkov/dnslookup"
  version "1.9.2"
  license "GPL-3.0-only"

  head do
    # version: HEAD
    # url "https://github.com/ameshkov/dnslookup/archive/refs/heads/main.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/ameshkov/dnslookup.git", branch: "main"

    # Warn: build.head doesn't work under "class"
    depends_on "go" => :build
    depends_on "upx" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  # TODO: quic-go doesn't build on Go 1.18 yet
  if build.without?("prebuilt") # || (OS.mac? && Hardware::CPU.arm?)
    # http downloading is quick than git cloning
    url "https://github.com/ameshkov/dnslookup/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/ameshkov/dnslookup.git", tag: "v#{version}"

    depends_on "go" => :build
    depends_on "upx" => :build
  elsif OS.mac? # && Hardware::CPU.intel?
    url "https://github.com/ameshkov/dnslookup/releases/download/v#{version}/dnslookup-darwin-amd64-v#{version}.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/ameshkov/dnslookup/releases/download/v#{version}/dnslookup-linux-amd64-v#{version}.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-32-bit?
    url "https://github.com/ameshkov/dnslookup/releases/download/v#{version}/dnslookup-linux-arm-v#{version}.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is-64-bit?
    url "https://github.com/ameshkov/dnslookup/releases/download/v#{version}/dnslookup-linux-arm64-v#{version}.tar.gz"
  end

  def install
    if build.without?("prebuilt") || build.head? # || (OS.mac? && Hardware::CPU.arm?)
      version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"
      buildpath_parent = File.dirname(buildpath)
      ENV["GOPATH"] = if File.basename(buildpath_parent).start_with? name.to_s
        "#{buildpath_parent}/go"
      else
        "#{buildpath}/.brew_home/go"
      end
      # Default GOCACHE: $HOMEBREW_CACHE/go_cache
      ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"

      # *std_go_args outputs binary to bin/
      system "go", "build", "-ldflags",
        "-X main.VersionString=#{version_str}",
        "-trimpath", "-o", name.to_s
      if !(OS.mac? && Hardware::CPU.arm?)
        system "upx", "-9", "-q", name.to_s
      end
    end

    bin.install "dnslookup"
    prefix.install_metafiles
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dnslookup -v")
    assert_match "dnslookup result", shell_output("#{bin}/dnslookup example.org tls://dns.google")
  end
end
