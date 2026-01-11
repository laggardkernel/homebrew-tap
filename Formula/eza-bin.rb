class EzaBin < Formula
  desc "Modern, maintained replacement for ls"
  homepage "https://github.com/eza-community/eza"
  version "0.23.4"
  resource_version=version.to_s
  license "EUPL-1.2"

  livecheck do
    # rubocop: disable all
    url "https://github.com/cargo-bins/cargo-quickinstall/releases?q=eza&expanded=true"
    # rubocop: enable all
    regex(%r{href=".*?/releases/tag/(?:eza-)?v?(\d+(?:\.\d+)+)"}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq.sort
    end
  end

  conflicts_with "eza", because: "they are variants of the same package"

  cpu_arch = Hardware::CPU.arm? ? "aarch64" : "x86_64"
  if OS.mac?
    basename = "eza-#{version}-#{cpu_arch}-apple-darwin.tar.gz"
    url "https://github.com/cargo-bins/cargo-quickinstall/releases/download/eza-#{version}/#{basename}"
  else
    basename = "eza_#{cpu_arch}-unknown-linux-gnu.tar.gz"
    url "https://github.com/eza-community/eza/releases/download/v#{version}/#{basename}"
  end

  resource "source" do
    url "https://github.com/eza-community/eza/archive/refs/tags/v#{resource_version}.tar.gz"
  end

  resource "man" do
    url "https://github.com/eza-community/eza/releases/download/v#{resource_version}/man-#{resource_version}.tar.gz"
  end

  def install
    bin.install "eza"

    resource("source").stage do
      prefix.install_metafiles

      bash_completion.install "completions/bash/eza"
      fish_completion.install "completions/fish/eza.fish"
      zsh_completion.install  "completions/zsh/_eza"
    end

    resource("man").stage do
      man1.install Dir["man-*/**/*.1"]
      man5.install Dir["man-*/**/*.5"]
    end
  end

  test do
    testfile = "test.txt"
    touch testfile
    assert_match testfile, shell_output(bin/"eza")

    # Test git integration
    flags = "--long --git --no-permissions --no-filesize --no-user --no-time --color=never"
    eza_output = proc { shell_output("#{bin}/eza #{flags}").lines.grep(/#{testfile}/).first.split.first }
    system "git", "init"
    assert_equal "-N", eza_output.call
    system "git", "add", testfile
    assert_equal "N-", eza_output.call
    system "git", "commit", "-m", "Initial commit"
    assert_equal "--", eza_output.call

    linkage_with_libgit2 = (bin/"eza").dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == (Formula["libgit2"].opt_lib/shared_library("libgit2")).realpath.to_s
    end

    assert linkage_with_libgit2, "No linkage with libgit2! Cargo is likely using a vendored version."
  end
end
