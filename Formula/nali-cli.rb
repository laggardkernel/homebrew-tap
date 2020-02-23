require "language/node"

class NaliCli < Formula
  desc "Parse geoinfo of IP Address without leaving your terminal"
  homepage "https://nali.skk.moe"
  # npm v nali-cli dist.tarball
  url "https://registry.npm.taobao.org/nali-cli/download/nali-cli-2.0.0.tgz"
  sha256 "aae02df85d6bb12527188cd89aa9cc241105b5f3a26763c44577e7346041e624"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/nali", "-h"
  end
end
