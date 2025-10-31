class MicromambaBin < Formula
  desc "Fast, robust, and cross-platform package manager"
  homepage "https://mamba.readthedocs.io/en/latest/"
  # homepage "https://github.com/mamba-org/mamba"
  version "2.3.3-0"
  license "BSD-3-Clause"

  livecheck do
    url "https://github.com/mamba-org/micromamba-releases"
    strategy :github_releases
    regex(/v?(\d+(?:\.\d+)+(-\d+)?)/i)
  end

  if OS.mac?
    os_name = "osx"
    cpu_arch = Hardware::CPU.intel? ? "64": "arm64"
  else
    os_name = "linux"
    if Hardware::CPU.ppc64le?
      cpu_arch = "ppc64le"
    elsif Hardware::CPU.arm?
      cpu_arch = "aarch64"
    else
      cpu_arch = "64"
    end
  end
  # micromamba-{os_name}-{cpu_arch}.tar.bz2
  name_middle = [os_name, cpu_arch].reject(&:empty?).join('-')
  url "https://github.com/mamba-org/micromamba-releases/releases/download/#{version}/micromamba-#{name_middle}.tar.bz2"

  def install
    bin.install "bin/micromamba"
    # Upstream chooses names based on static or dynamic linking,
    # but as of 2.0 they provide identical interfaces.
    bin.install_symlink "micromamba" => "mamba"
  end

  def caveats
    <<~EOS
      Please run the following to setup your shell:
        #{opt_bin}/mamba shell init --shell <your-shell> --root-prefix ~/mamba
      and restart your terminal.
    EOS
  end

  test do
    ENV["MAMBA_ROOT_PREFIX"] = testpath.to_s

    assert_match version.to_s, shell_output("#{bin}/mamba --version").strip
    assert_match version.to_s, shell_output("#{bin}/micromamba --version").strip

    # Using 'xtensor' (header-only package) to avoid "broken pipe" codesigning issue
    # encountered on macOS 13-arm and 14-arm during CI.
    system bin/"mamba", "create", "-n", "test", "xtensor", "-y", "-c", "conda-forge"
    assert_path_exists testpath/"envs/test/include/xtensor.hpp"
  end
end
