class ImSelectBin < Formula
  desc "Switch your input method through terminal"
  homepage "https://github.com/daipeihust/im-select"
  # rubocop: disable all
  version "11ed927"
  url "https://github.com/daipeihust/im-select/archive/#{version}.tar.gz"
  # rubocop: enable all
  license "MIT"
  revision 1

  livecheck do
    url "https://github.com/daipeihust/im-select/commits/master/macOS/out/apple/im-select"
    regex(%r{href="/daipeihust/im-select/tree/([a-z0-9]{7,}+)" }i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  depends_on :macos

  def install
    # Xcode is needed for compiling to get the executable that is less than 30k.
    # Skip building from the source, download the binary release directly.
    bin_file = if Hardware::CPU.arm?
      "macOS/out/apple/im-select"
    else
      "macOS/out/intel/im-select"
    end

    bin.install bin_file.to_s
    prefix.install_metafiles
  end

  test do
    system bin/"im-select"
  end
end
