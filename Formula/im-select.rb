class ImSelect < Formula
  desc "Switch your input method through terminal"
  homepage "https://github.com/daipeihust/im-select"
  # rubocop: disable all
  version "1.0.1"
  url "https://raw.githubusercontent.com/daipeihust/im-select/#{version}/im-select-mac/out/im-select"
  # rubocop: enable all
  license "MIT"

  def install
    # Xcode is needed for compiling to get the executable that is less than 30k.
    # Skip building from the source, download the binary release directly.
    bin.install "im-select"
  end

  test do
    system bin/"im-select"
  end
end
