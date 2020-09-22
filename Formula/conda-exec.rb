class CondaExec < Formula
  desc "Hermetic conda executable in a sinlge file"
  homepage "https://repo.anaconda.com/pkgs/misc/conda-execs/"
  url "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-4.7.12-osx-64.exe"
  sha256 "664985c0f85291a1be3aee3cd00d3a93dd29ffe191cacfd54e2c84443548a31c"
  head "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-latest-osx-64.exe"

  bottle :unneeded

  def install
    bin.install Dir["conda-*-osx-64.exe"][0] => "conda-exec"
  end

  test do
    system bin/"conda-exec", "-h"
  end

end
