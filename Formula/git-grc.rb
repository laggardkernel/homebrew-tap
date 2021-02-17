class GitGrc < Formula
  desc "Standardized Git submission tool"
  homepage "https://github.com/sdttttt/gcr"
  version "1.0.0"
  url "https://github.com/sdttttt/gcr/archive/v#{version}.tar.gz"
  sha256 "d44b1386cf5c1285d7e2f6f3e4324979939afdf1d2a30382db621996af85522e"
  license "MIT"

  bottle :unneeded

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    # TODO: gcr or grc, one of which is a mistake made by the project author
    # # Cancel git-cz linkage, conflict_with "commitizen"
    # cd(bin) do
    #   ln_s "grc", "git-cz"
    # end
  end

  test do
    system "#{bin}/grc", "--help"
  end
end
