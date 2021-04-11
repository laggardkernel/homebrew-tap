class CondaExec < Formula
  desc "Hermetic conda executable in a sinlge file"
  homepage "https://repo.anaconda.com/pkgs/misc/conda-execs/"
  version "4.7.12"

  bottle :unneeded

  if OS.mac?
    url "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-#{version}-osx-64.exe"
    sha256 "664985c0f85291a1be3aee3cd00d3a93dd29ffe191cacfd54e2c84443548a31c"
  end
  if OS.linux?
    url "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-#{version}-linux-64.exe"
  end

  head do
    if OS.mac?
      url "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-latest-osx-64.exe"
    end
    if OS.linux?
      url "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-latest-linux-64.exe"
    end
  end

  def install
    Dir["conda*"].each do |i|
      bin.install i => "conda-exec"
      break
    end
  end

  test do
    system bin/"conda-exec", "-h"
  end
end
# Ref
# - https://github.com/conda/conda/issues/9401
# - https://stackoverflow.com/a/54563455/5101148
# - https://repo.anaconda.com/pkgs/misc/conda-execs/ (channel misc deprecated)
# - https://anaconda.org/conda-forge/conda-standalone/files
