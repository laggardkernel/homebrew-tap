require "language/node"

class CzCli < Formula
  desc "Standardize commit msg format"
  homepage "https://github.com/commitizen/cz-cli"
  # npm v commitizen dist.tarball
  url "https://registry.npmjs.org/commitizen/-/commitizen-4.2.1.tgz"
  sha256 "ea0f069f7d14d31030f248f631b1e18275cf3c2a1bf1a8583ce1698c6274b706"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/git-cz", "-h"
  end
end
