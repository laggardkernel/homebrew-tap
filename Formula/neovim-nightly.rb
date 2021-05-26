class NeovimNightly < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  version "latest"
  url "https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz"
  # sha256
  license "Apache-2.0"

  livecheck do
    skip "No version information available"
  end

  def install
    sources = Dir.entries(".")
    sources -= Dir.glob(".*")
    cp_r sources, "#{prefix}"
  end

  test do
    (testpath/"test.txt").write("Hello World from Vim!!")
    system bin/"nvim", "--headless", "-i", "NONE", "-u", "NONE",
      "+s/Vim/Neovim/g", "+wq", "test.txt"
    assert_equal "Hello World from Neovim!!", (testpath/"test.txt").read.chomp
  end
end
