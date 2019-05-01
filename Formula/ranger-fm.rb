class RangerFm < Formula
  include Language::Python::Virtualenv

  desc "Vim-like file manager"
  homepage "https://github.com/ranger/ranger"
  url "https://files.pythonhosted.org/packages/6c/95/a5a211e35084ac72cd427702dcc13982ddfbd7145522f68fd15b366e4201/ranger-fm-1.9.2.tar.gz"
  sha256 "0ec62031185ad1f40b9faebd5a2d517c8597019c2eee919e3f1c60ce466d8625"
  head "https://github.com/ranger/ranger.git"

  # Depends on python@2 for the time being, cause:
  # 1. ranger based on python 3 breaks iTerm image preview
  #    https://github.com/ranger/ranger/issues/1546
  # 2. Using python@2 instead of the system one is recommended by the community
  #    https://github.com/Homebrew/homebrew-core/issues/26287
  depends_on "python@2"

  def install
    virtualenv_install_with_resources
    man1.install "doc/ranger.1"
    doc.install "examples"
  end

  def post_install
    system libexec/"bin/pip", "install", "-U", "chardet"
    system libexec/"bin/pip", "install", "-U", "Pillow"
  end

  test do
    assert_match version.to_s, shell_output("script -q /dev/null #{bin}/ranger --version")
  end
end
