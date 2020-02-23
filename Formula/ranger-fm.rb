class RangerFm < Formula
  include Language::Python::Virtualenv

  desc "Vim-like file manager"
  homepage "https://github.com/ranger/ranger"
  url "https://files.pythonhosted.org/packages/7e/19/a7d9bb8646f87df5a3126fc385e45c04e55639c0576d31351083cb02f248/ranger-fm-1.9.3.tar.gz"
  sha256 "9476ed1971c641f4ba3dde1b8b80387f0216fcde3507426d06871f9d7189ac5e"
  head "https://github.com/ranger/ranger.git"

  # Depends on python@2 for the time being, cause:
  # 1. ranger based on python 3 breaks iTerm image preview
  #    https://github.com/ranger/ranger/issues/1546
  # 2. Using python@2 instead of the system one is recommended by the community
  #    https://github.com/Homebrew/homebrew-core/issues/26287
  depends_on "python"

  def install
    virtualenv_install_with_resources
    man1.install "doc/ranger.1"
    doc.install "examples"
  end

  def post_install
    # chardet, improve encoding detection
    system libexec/"bin/pip", "install", "-U", "chardet"
    # python-bidi, correct display of RTL file names
    system libexec/"bin/pip", "install", "-U", "python-bidi"
    # Pillow, image display for kitty
    system libexec/"bin/pip", "install", "-U", "Pillow"
  end

  test do
    assert_match version.to_s, shell_output("script -q /dev/null #{bin}/ranger --version")
  end
end
