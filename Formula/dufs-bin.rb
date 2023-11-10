class DufsBin < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  version "0.37.1"
  license any_of: ["Apache-2.0", "MIT"]
  # sha256 ""

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    url "https://github.com/sigoden/dufs/archive/v#{version}.tar.gz"
    depends_on "rust" => :build
  else
    if OS.mac? && Hardware::CPU.intel?
      url "https://github.com/sigoden/dufs/releases/download/v#{version}/dufs-v#{version}-x86_64-apple-darwin.tar.gz"
    elsif OS.mac? && Hardware::CPU.arm?
      url "https://github.com/sigoden/dufs/releases/download/v#{version}/dufs-v#{version}-aarch64-apple-darwin.tar.gz"
    elsif OS.linux? && Hardware::CPU.intel?
      url "https://github.com/sigoden/dufs/releases/download/v#{version}/dufs-v#{version}-x86_64-unknown-linux-musl.tar.gz"
    elsif OS.linux? && Hardware::CPU.arm? && !Hardware::CPU.is_64_bit?
      url "https://github.com/sigoden/dufs/releases/download/v#{version}/dufs-v#{version}-aarch64-unknown-linux-musl.tar.gz"
    end
  end

  def install
    if build.without?("prebuilt")
      system "cargo", "install", *std_cargo_args
    else
      bin.install "dufs"
    end
    prefix.install_metafiles
    generate_completions_from_executable(bin/"dufs", "--completions")
  end

  test do
    port = free_port
    pid = fork do
      exec "#{bin}/dufs", bin.to_s, "-b", "127.0.0.1", "--port", port.to_s
    end

    sleep 2

    begin
      read = (bin/"dufs").read
      assert_equal read, shell_output("curl localhost:#{port}/dufs")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
