class DufsBin < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  version "0.45.0"
  license any_of: ["Apache-2.0", "MIT"]

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  conflicts_with "dufs", because: "they are variants of the same package"

  depends_on "xz"  # wierd running dependency

  if build.without?("prebuilt")
    url "https://github.com/sigoden/dufs/archive/v#{version}.tar.gz" # rubocop: disable all
    depends_on "rust" => :build
  else
    os_name_part = OS.mac? ? "apple-darwin": "unknown-linux-musl"
    if Hardware::CPU.arm?
      cpu_arch = "aarch64"
    else
      cpu_arch = "x86_64"
    end
    basename = "dufs-v#{version}-#{cpu_arch}-#{os_name_part}.tar.gz"
    url "https://github.com/sigoden/dufs/releases/download/v#{version}/#{basename}"
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
