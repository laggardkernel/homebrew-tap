class MongoshBin < Formula
  desc "MongoDB Shell to connect, configure, query, and work with your MongoDB database"
  homepage "https://github.com/mongodb-js/mongosh#readme"
  version "2.5.5"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/mongodb-js/mongosh/releases" # rubocop: disable all
    regex(%r{href=.*?/releases/tag/v?(\d+(?:\.\d+)+(-[^"]+)?)"}i)
    strategy :page_match do |page|
      page.scan(regex).map { |match| match&.first }
    end
  end

  conflicts_with "mongosh", because: "they are variants of the same package"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/mongodb-js/mongosh/releases/download/v#{version}/mongosh-#{version}-darwin-x64.zip"
  elsif OS.mac? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/mongodb-js/mongosh/releases/download/v#{version}/mongosh-#{version}-darwin-arm64.zip"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/mongodb-js/mongosh/releases/download/v#{version}/mongosh-#{version}-linux-x64.zip"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/mongodb-js/mongosh/releases/download/v#{version}/mongosh-#{version}-linux-arm64.zip"
  end

  def install
    bin.install Dir["bin/*"].reject { |f| File.basename(f).include?(".") }
    lib.install Dir["*/*.dylib"]
    man1.install Dir["*.1.gz"]
    prefix.install_metafiles
  end

  test do
    assert_match "ECONNREFUSED 0.0.0.0:1", shell_output("#{bin}/mongosh \"mongodb://0.0.0.0:1\" 2>&1", 1)
    assert_match "#ok#", shell_output("#{bin}/mongosh --nodb --eval \"print('#ok#')\"")
    assert_match "all tests passed", shell_output("#{bin}/mongosh --smokeTests 2>&1")
  end
end
