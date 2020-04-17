require "language/node"

class NaliCli < Formula
  desc "Parse geoinfo of IP Address without leaving your terminal"
  homepage "https://nali.skk.moe"
  # npm v nali-cli dist.tarball
  url "https://registry.npm.taobao.org/nali-cli/download/nali-cli-2.1.3.tgz"
  sha256 "698cd2c5fddc1fe9b8656bda411a7fcba714ee8296b3146189a881a64d376d51"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/nali", "-h"
  end
end
