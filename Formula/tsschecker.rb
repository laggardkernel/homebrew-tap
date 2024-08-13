class Tsschecker < Formula
  desc "Powerfull tool to check tss signing status of various devices and firmwares"
  homepage "https://github.com/tihmstar/tsschecker"
  version "343"
  url "https://github.com/tihmstar/tsschecker/releases/download/#{version}/tsschecker_macOS_v#{version}.zip"
  # sha256 ""
  license "LGPL-3.0"

  def install
    # binary name: clash-darwin-amd64-2021.02.21
    bin.install Dir.glob("tsschecker*")[0] => "tsschecker"
    prefix.install_metafiles
  end

  test do
    system "#{bin}/tsschecker", "--help"
  end
end
