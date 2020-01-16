require "language/node"

class NaliCli < Formula
  desc "Parse geoinfo of IP Address without leaving your terminal"
  homepage "https://nali.skk.moe"
  # npm v nali-cli dist.tarball
  url "https://registry.npm.taobao.org/nali-cli/download/nali-cli-1.0.0.tgz"
  sha256 "47066db13308699408efd982f21a52a3bdc26a0bede5f6d8d5956aae77f35a88"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/nali", "-h"
  end
end
