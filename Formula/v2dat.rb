class V2dat < Formula
  desc "Cli tool that can unpack v2ray data packages"
  homepage "https://github.com/urlesistiana/v2dat"
  # rubocop: disable all
  version "47b8ee5"
  url "https://github.com/urlesistiana/v2dat/archive/#{version}.tar.gz"
  # rubocop: enable all
  license "GPL-3.0"

  # version: HEAD
  # url "https://github.com/urlesistiana/v2dat/archive/refs/heads/main.zip"
  # Git repo is not cloned into a sub-folder. version, HEAD-1234567
  head "https://github.com/urlesistiana/v2dat.git", branch: "main"

  livecheck do
    url "https://github.com/urlesistiana/v2dat/commits/main"
    regex(%r{href="/urlesistiana/v2dat/tree/([a-z0-9]{7,}+)" }i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  depends_on "go" => :build
  # TODO(lk): upx breaks the executable
  # depends_on "upx" => :build # rubocop: disable all

  def install
    # version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"
    buildpath_parent = File.dirname(buildpath)
    ENV["GOPATH"] = if File.basename(buildpath_parent).start_with? "v2dat"
      "#{buildpath_parent}/go"
    else
      "#{buildpath}/.brew_home/go"
    end
    # Default GOCACHE: $HOMEBREW_CACHE/go_cache
    ENV["GOCACHE"] = "#{ENV["GOPATH"]}/go-cache"

    mkdir_p "#{buildpath}/release"
    system "go", "build", *std_go_args(ldflags: "-s -w"), "-trimpath", "-o", "release/v2dat", "."
    # system "upx", "-9", "-q", "v2dat"
    bin.install "release/v2dat"
    prefix.install_metafiles
  end
end
