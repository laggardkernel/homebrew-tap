class GitGrc < Formula
  desc "Standardized Git submission tool"
  homepage "https://github.com/sdttttt/gcr"
  url "https://github.com/sdttttt/gcr/archive/v0.9.1.tar.gz"
  sha256 "e33d20e788746bbff30f60babe76b99518cc813aa12241f3c1895ad42732c1c1"
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
