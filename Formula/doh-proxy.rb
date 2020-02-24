class DohProxy < Formula
  include Language::Python::Virtualenv

  desc "A proof of concept DNS-Over-HTTPS proxy implementing IETF Draft draft-ietf-doh-dns-over-https"
  homepage "https://facebookexperimental.github.io/doh-proxy/"
  url "https://files.pythonhosted.org/packages/e9/3c/ab7adef67f5aac0efeba187caf71762b97122152e07a2e4c584ea82478ec/doh-proxy-0.0.9.tar.gz"
  sha256 "d7f17652327bdad6399364d263d4d2f1728a7ebb159dccb22f67eef66fecbfbb"
  head "https://github.com/facebookexperimental/doh-proxy.git"

  conflicts_with "dns-over-https", :because => "both install binaries `doh-proxy`, `doh-client`"

  depends_on "python"

  # aioh2 is fucking dead, install from git drectly
  # https://github.com/decentfox/aioh2/issues/21
  # resource "aioh2" do
  #   url "https://files.pythonhosted.org/packages/44/91/7fe6c06690b53bf105a6bf93ec3c38a20e40f578bd8e1fda0d9accf728fd/aioh2-0.2.2.tar.gz"
  #   sha256 "8da7b49261d9bbfe71b3b9e994eca1fcc53890c7868fc96eb6b9027e3f27220e"
  # end

  resource "aiohttp" do
    url "https://files.pythonhosted.org/packages/00/94/f9fa18e8d7124d7850a5715a0b9c0584f7b9375d331d35e157cee50f27cc/aiohttp-3.6.2.tar.gz"
    sha256 "259ab809ff0727d0e834ac5e8a283dc5e3e0ecc30c4d80b3cd17a4139ce1f326"
  end

  resource "aiohttp-remotes" do
    url "https://files.pythonhosted.org/packages/cd/2f/93e9198a01485f588d12e19c87cd277542dc28d8b31dc8e1c09fa1c75548/aiohttp_remotes-0.1.2.tar.gz"
    sha256 "43c3f7e1c5ba27f29fb4dbde5d43b900b5b5fc7e37bf7e35e6eaedabaec4a3fc"
  end

  resource "async-timeout" do
    url "https://files.pythonhosted.org/packages/a1/78/aae1545aba6e87e23ecab8d212b58bb70e72164b67eb090b81bb17ad38e3/async-timeout-3.0.1.tar.gz"
    sha256 "0c3c816a028d47f659d6ff5c745cb2acf1f966da1fe5c19c77a70282b25f4c5f"
  end

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/98/c3/2c227e66b5e896e15ccdae2e00bbc69aa46e9a8ce8869cc5fa96310bf612/attrs-19.3.0.tar.gz"
    sha256 "f7b7ce16570fe9965acd6d30101a28f62fb4a7f9e926b3bbc9b61f8b04247e72"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"
    sha256 "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"
  end

  resource "dnspython" do
    url "https://files.pythonhosted.org/packages/ec/c5/14bcd63cb6d06092a004793399ec395405edf97c2301dfdc146dfbd5beed/dnspython-1.16.0.zip"
    sha256 "36c5e8e38d4369a08b6780b7f27d790a292b2b08eea01607865bf0936c558e01"
  end

  resource "h2" do
    url "https://files.pythonhosted.org/packages/08/0a/033df0fc05fe94f72517ccd393dd9ff99b1773fd198307638e6d3568a518/h2-3.2.0.tar.gz"
    sha256 "875f41ebd6f2c44781259005b157faed1a5031df3ae5aa7bcb4628a6c0782f14"
  end

  resource "hpack" do
    url "https://files.pythonhosted.org/packages/44/f1/b4440e46e265a29c0cb7b09b6daec6edf93c79eae713cfed93fbbf8716c5/hpack-3.0.0.tar.gz"
    sha256 "8eec9c1f4bfae3408a3f30500261f7e6a65912dc138526ea054f9ad98892e9d2"
  end

  resource "hyperframe" do
    url "https://files.pythonhosted.org/packages/e6/7f/9a4834af1010dc1d570d5f394dfd9323a7d7ada7d25586bd299fc4cb0356/hyperframe-5.2.0.tar.gz"
    sha256 "a9f5c17f2cc3c719b917c4f33ed1c61bd1f8dfac4b1bd23b7c80b3400971b41f"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/cb/19/57503b5de719ee45e83472f339f617b0c01ad75cba44aba1e4c97c2b0abd/idna-2.9.tar.gz"
    sha256 "7588d1c14ae4c77d74036e8c22ff447b26d0fde8f007354fd48a7814db15b7cb"
  end

  resource "multidict" do
    url "https://files.pythonhosted.org/packages/b6/22/ae21cedaa0e6d35e84e8ab57700dcf3d4609421ebe113e1aaafc468eec42/multidict-4.7.4.tar.gz"
    sha256 "d7d428488c67b09b26928950a395e41cc72bb9c3d5abfe9f0521940ee4f796d4"
  end

  resource "priority" do
    url "https://files.pythonhosted.org/packages/ba/96/7d0b024087062418dfe02a68cd6b195399266ac002fb517aad94cc93e076/priority-1.3.0.tar.gz"
    sha256 "6bc1961a6d7fcacbfc337769f1a382c8e746566aaa365e78047abe9f66b2ffbe"
  end

  resource "yarl" do
    url "https://files.pythonhosted.org/packages/d6/67/6e2507586eb1cfa6d55540845b0cd05b4b77c414f6bca8b00b45483b976e/yarl-1.4.2.tar.gz"
    sha256 "58cd9c469eced558cd81aa3f484b2924e8897049e06889e8ff2510435b7ef74b"
  end

  def install
    virtualenv_install_with_resources
  end

  def post_install
    # aioh2 is fucking dead, install from git drectly
    # https://github.com/decentfox/aioh2/issues/21
    system libexec/"bin/pip", "install", "--force-reinstall", "-U", "git+https://github.com/URenko/aioh2.git"
  end

  test do
    assert_match version.to_s, shell_output("script -q /dev/null #{bin}/doh-client --version")
  end
end
