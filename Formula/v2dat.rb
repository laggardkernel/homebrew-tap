class V2dat < Formula
  desc "Cli tool that can unpack v2ray data packages"
  homepage "https://github.com/urlesistiana/v2dat"
  # HEAD only, no regular release
  version "0.0.0"
  # url "https://github.com/urlesistiana/v2dat/archive/release-#{version}.tar.gz"
   url "https://github.com/urlesistiana/v2dat/archive/main.tar.gz"
  license "GPL-3.0"
  revision 0

  livecheck do
    skip "HEAD only"
  end

  head do
    # version: HEAD
    # url "https://github.com/urlesistiana/v2dat/archive/refs/heads/main.zip"
    # Git repo is not cloned into a sub-folder. version, HEAD-1234567
    url "https://github.com/urlesistiana/v2dat.git", branch: "main"
  end

  depends_on "go" => :build
  # TODO(lk): upx breaks the executable
  # depends_on "upx" => :build

  def install
    version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"
    buildpath_parent = File.dirname(buildpath)
    ENV["GOPATH"] = if File.basename(buildpath_parent).start_with? "v2dat"
      "#{buildpath_parent}/go"
    else
      "#{buildpath}/.brew_home/go"
    end
    # Default GOCACHE: $HOMEBREW_CACHE/go_cache
    ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"

    mkdir_p "#{buildpath}/release"
    cd "#{buildpath}/release"
    system "go", "build", *std_go_args(ldflags: "-s -w"), "-trimpath", "-o", "v2dat", "../"
    # system "upx", "-9", "-q", "v2dat"
    cp "../README.md", "."
    cp "../LICENSE", "."

    bin.install "v2dat"
    prefix.install_metafiles
  end
end
