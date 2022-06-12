class CondaStandalone < Formula
  desc "Entry point and dependency collection for PyInstaller-based standalone conda"
  homepage "https://anaconda.org/conda-forge/conda-standalone"
  version "4.12.0,h694c41f_0"
  url "https://anaconda.org/conda-forge/conda-standalone/#{version.to_s.split(",").first}/download/osx-64/conda-standalone-#{version.to_s.split(",").first}-#{version.to_s.split(",").second}.tar.bz2"

  livecheck do
    url "https://anaconda.org/conda-forge/conda-standalone/files"
    regex(%r{href=.*?/osx.*?/conda[_-]standalone[_-]v?(\d+(?:\.\d+)+)[_-](.+?)\.tar\.bz2}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match&.first + "," + match&.second
      end
    end
  end

  depends_on arch: :x86_64 # no arm64 build provided
  # Only support macOS temporarily, cause the version strings are different for
  #  macOS and Linux. Don't bother to fetch version numbers separately.
  depends_on :macos

  def install
    bin.install Dir["*/conda*"][0] => "conda-exec"
  end

  def caveats
    <<~EOS
      To avoid name conflict with 'conda' install from Anaconda or Miniconda,
      the executable is named as 'conda-exec'.
    EOS
  end

  test do
    assert_match version.to_s.split(",").first, shell_output("#{bin}/conda-exec --version")
  end
end
# Ref
# - https://github.com/conda/conda/issues/9401
# - https://stackoverflow.com/a/54563455/5101148
# - https://repo.anaconda.com/pkgs/misc/conda-execs/ (channel misc deprecated)
# - https://anaconda.org/search?q=conda-standalone
