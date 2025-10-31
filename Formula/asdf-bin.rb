class AsdfBin < Formula
  desc "Extendable version manager with support for Ruby, Node.js, Erlang & more"
  homepage "https://asdf-vm.com/"
  version "0.18.0"
  license "MIT"
  revision 0

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  conflicts_with "asdf", because: "they are variants of the same package"

  os_name = OS.mac? ? "darwin" : "linux"
  if Hardware::CPU.intel?
    if OS.linux? && Hardware::CPU.is_32_bit?
      cpu_arch = "386"
    else
      cpu_arch = "amd64"
    end
  elsif Hardware::CPU.arm?
    cpu_arch = "arm64"
  end
  basename = "asdf-v#{version}-#{os_name}-#{cpu_arch}.tar.gz"
  url "https://github.com/asdf-vm/asdf/releases/download/v#{version}/#{basename}"

  def install
    bin.install "asdf"
    generate_completions_from_executable(bin/"asdf", "completion")
  end

  def caveats
    <<~EOS
      asdf has been completely rewritten in Go as of version 0.16.0.
      Manual sourcing file like asdf.sh or asdf.fish, is no longer required to
      activate asdf. Cuz 'asdf shell' command has been removed.

      For details on the changes and migration steps, see:

      - https://asdf-vm.com/guide/upgrading-to-v0-16.html
      - https://asdf-vm.com/guide/getting-started.html
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asdf version")
    assert_match "No plugins installed", shell_output("#{bin}/asdf plugin list 2>&1")
  end
end
