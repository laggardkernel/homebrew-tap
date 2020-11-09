class GitGrc < Formula
  desc "Standardized Git submission tool"
  homepage "https://github.com/sdttttt/gcr"
  url "https://github.com/sdttttt/gcr/archive/v0.8.2.tar.gz"
  sha256 "0e798cf2e6a9250e96f1f362c003328c075358986bb0e0fe00cdf4501d5107da"
  license "MIT"

  bottle :unneeded

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    # For use of "git cz"
    cd(bin) do
      ln_s "grc", "git-cz"
    end
  end

  test do
    system "#{bin}/grc", "--help"
  end
end
