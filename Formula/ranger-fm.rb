class RangerFm < Formula
  include Language::Python::Virtualenv

  desc "Vim-like file manager"
  homepage "https://github.com/ranger/ranger"
  url "https://files.pythonhosted.org/packages/6c/95/a5a211e35084ac72cd427702dcc13982ddfbd7145522f68fd15b366e4201/ranger-fm-1.9.2.tar.gz"
  sha256 "0ec62031185ad1f40b9faebd5a2d517c8597019c2eee919e3f1c60ce466d8625"
  head "https://github.com/ranger/ranger.git"

  # depends_on "python@2"

  # resource "Pillow" do
  #   url "https://files.pythonhosted.org/packages/81/1a/6b2971adc1bca55b9a53ed1efa372acff7e8b9913982a396f3fa046efaf8/Pillow-6.0.0.tar.gz"
  #   sha256 "809c0a2ce9032cbcd7b5313f71af4bdc5c8c771cb86eb7559afd954cab82ebb5"
  # end

  def install
    virtualenv_install_with_resources

    # venv = virtualenv_create(libexec, "python3")
    # system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:",
    #                           "--ignore-installed", buildpath
    # system libexec/"bin/pip", "uninstall", "-y", name
    # venv.pip_install "Pillow"
    # venv.pip_install_and_link buildpath

    man1.install "doc/ranger.1"
    doc.install "examples"
  end

  def post_install
    system libexec/"bin/pip", "install", "-U", "Pillow"
  end

  test do
    assert_match version.to_s, shell_output("script -q /dev/null #{bin}/ranger --version")
  end
end
