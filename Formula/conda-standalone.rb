class CondaStandalone < Formula
  desc "Entry point and dependency collection for PyInstaller-based standalone conda"
  homepage "https://anaconda.org/anaconda/conda-standalone"
  version "25.3.1,h3fdc52a_0,hc14cd2a_0"

  if OS.mac? && Hardware::CPU.intel?
    url "https://anaconda.org/anaconda/conda-standalone/#{version.to_s.split(",").first}/download/osx-64/conda-standalone-#{version.to_s.split(",").first}-#{version.to_s.split(",").second}.tar.bz2"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://anaconda.org/anaconda/conda-standalone/#{version.to_s.split(",").first}/download/osx-arm64/conda-standalone-#{version.to_s.split(",").first}-#{version.to_s.split(",").third}.tar.bz2"
  end

  livecheck do
    url "https://anaconda.org/anaconda/conda-standalone/files"
    regex(%r{href=.*?/osx-(.*?)/conda[_-]standalone[_-]v?(\d+(?:\.\d+)+)[_-](.+?)\.tar.bz2}i)
    strategy :page_match do |page, regex|
      version_map = Hash.new { |hash, key| hash[key] = {} }

      page.scan(regex).each do |match|
        arch, version, build = match
        next if version_map[version].key?(arch) && compare_builds(version_map[version][arch], build)

        version_map[version][arch] = build
      end

      version_map.map do |version, builds|
        # Ensure '64' is first, then 'arm64', followed by any other architectures
        ordered_builds = ["64", "arm64"].map { |arch| builds.fetch(arch, "-") }
        ordered_builds.map! { |build| build.empty? ? "-" : build }
        ordered_builds += builds.except("64", "arm64").values
        "#{version},#{ordered_builds.join(",")}"
      end
    end

    def compare_builds(build1, build2)
      build1.split("_").last.to_i > build2.split("_").last.to_i
    end
  end

  # osx-arm64 builds are provided >= 23.11.0-
  # Only support macOS temporarily, cause the version strings are different for
  #  macOS and Linux. Don't bother to fetch version numbers separately.
  depends_on :macos

  def install
    bin.install Dir["standalone_conda/conda*"][0] => "conda-exec"
    prefix.install_metafiles
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
