class AsdfBin < Formula
  desc "Extendable version manager with support for Ruby, Node.js, Erlang & more"
  homepage "https://asdf-vm.com/"
  version "0.17.0"
  resource_version=version.to_s
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  conflicts_with "asdf", because: "they are variants of the same package"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/asdf-vm/asdf/releases/download/v#{version}/asdf-v#{version}-darwin-arm64.tar.gz"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/asdf-vm/asdf/releases/download/v#{version}/asdf-v#{version}-darwin-amd64.tar.gz"
  end

  resource "source" do
    url "https://github.com/asdf-vm/asdf/archive/refs/tags/v#{resource_version}.tar.gz"
  end

  def install
    bin.install "asdf"
    generate_completions_from_executable(bin/"asdf", "completion")
    resource("source").stage do
      libexec.install Dir["asdf.*"]
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asdf version")
    assert_match "No plugins installed", shell_output("#{bin}/asdf plugin list 2>&1")
  end
end
