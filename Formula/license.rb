class License < Formula
  desc "Generate software license files on the command line"

  # homepage "https://github.com/nishanths/license"
  # head "https://github.com/nishanths/license.git"
  # url "https://github.com/jfoster/license/archive/v1.0.0.tar.gz"
  # sha256 "7918b695695aa5c8489ab5838ba57cebf64d608646fc8f828b4a250ad910cf08"

  # Use the fork from jfoster, which is newer
  homepage "https://github.com/jfoster/license"
  head "https://github.com/jfoster/license.git"
  url "https://github.com/jfoster/license/archive/v1.0.1.tar.gz"
  sha256 "c7a9707538cd3c91fd8a98889d9e0daab3824b9d646beb3d22d53792decb1665"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    path = buildpath/"src/github.com/nishanths/license"
    path.install Dir["*"]

    cd path do
      system "go", "build", "-o", bin/"license"

      prefix.install_metafiles
    end
  end

  test do
    system bin/"license", "--help"
  end
end
