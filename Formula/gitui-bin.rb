class GituiBin < Formula
  desc "Blazing fast terminal-ui for git written in rust"
  homepage "https://github.com/extrawurst/gitui"
  version "0.26.3"
  license "MIT"
  revision 1

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  conflicts_with "gitui", because: "they are variants of the same package"

  if build.without?("prebuilt")
    url "https://github.com/extrawurst/gitui/archive/v#{version}.tar.gz" # rubocop: disable all
    depends_on "rust" => :build
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/extrawurst/gitui/releases/download/v#{version}/gitui-mac.tar.gz"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/extrawurst/gitui/releases/download/v#{version}/gitui-mac-x86.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel? && (Hardware::CPU.is-64-bit?)
    url "https://github.com/extrawurst/gitui/releases/download/v#{version}/gitui-linux-x86_64.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-64-bit?)
    url "https://github.com/extrawurst/gitui/releases/download/v#{version}/gitui-linux-aarch64.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm? && (Hardware::CPU.is-32-bit?)
    url "https://github.com/extrawurst/gitui/releases/download/v#{version}/gitui-linux-armv7.tar.gz"
  end
  uses_from_macos "zlib"

  def install
    if build.without?("prebuilt")
      system "cargo", "install", *std_cargo_args
    else
      bin.install "gitui"
    end
    prefix.install_metafiles
  end

  test do
    system "git", "clone", "https://github.com/extrawurst/gitui.git"
    (testpath/"gitui").cd { system "git", "checkout", "v0.7.0" }

    input, _, wait_thr = Open3.popen2 "script -q screenlog.ansi"
    input.puts "stty rows 80 cols 130"
    input.puts "env LC_CTYPE=en_US.UTF-8 LANG=en_US.UTF-8 TERM=xterm #{bin}/gitui -d gitui"
    sleep 1
    # select log tab
    input.puts "2"
    sleep 1
    # inspect commit (return + right arrow key)
    input.puts "\r"
    sleep 1
    input.puts "\e[C"
    sleep 1
    input.close

    screenlog = (testpath/"screenlog.ansi").read
    # remove ANSI colors
    screenlog.encode!("UTF-8", "binary",
      invalid: :replace,
      undef:   :replace,
      replace: "")
    screenlog.gsub!(/\e\[([;\d]+)?m/, "")
    assert_match "Author: Stephan Dilly", screenlog
    assert_match "Date: 2020-06-15", screenlog
    assert_match "Sha: 9c2a31846c417d8775a346ceaf38e77b710d3aab", screenlog
  ensure
    Process.kill("TERM", wait_thr.pid)
  end
end
