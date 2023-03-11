class Otfcc < Formula
  desc "Parses & writes SFNT structures"
  homepage "https://github.com/caryll/otfcc"
  version "0.10.4"
  license "Apache-2.0"

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  livecheck do
    skip "Project archived, end of life"
  end

  # sha256: skipped, too complicated
  if build.without?("prebuilt")
    # http downloading is quick than git cloning
    url "https://github.com/caryll/otfcc/archive/refs/tags/v#{version}.tar.gz"
    # Git repo is not cloned into a sub-folder
    # url "https://github.com/caryll/otfcc.git", tag: "v#{version}"

    depends_on xcode: :build
  # elsif OS.mac? && Hardware::CPU.intel?
  elsif OS.mac?
    url "https://github.com/caryll/otfcc/releases/download/v#{version}/otfcc-macos.x64-#{version}.zip"
    # sha256 "d9c74825ddac700eb429de31de7cb0a249636f47c6a4cc64eaa102a40966cf00"
  end

  def install
    if build.without?("prebuilt") || build.head?
      # ENV.deparallelize  # if your formula fails when building in parallel
      system "./dep/bin-osx/premake5", "xcode4"
      system "xcodebuild",
                "-workspace", "build/xcode/otfcc.xcworkspace",
                "-scheme", "otfccbuild",
                "-configuration", "Release"
      system "xcodebuild",
                "-workspace", "build/xcode/otfcc.xcworkspace",
                "-scheme", "otfccdump",
                "-configuration", "Release"

      bin.install "bin/release-x64/otfccbuild"
      bin.install "bin/release-x64/otfccdump"
    else
      bin.install "otfccbuild"
      bin.install "otfccdump"
    end
    prefix.install_metafiles
  end

  test do
    system "#{bin}/otfccbuild", "--version"
  end
end
# https://github.com/caryll/homebrew-tap/blob/master/otfcc-mac64.rb
