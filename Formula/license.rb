class License < Formula
  desc "Generate license files on the command-line"

  # homepage "https://github.com/nishanths/license"
  # head "https://github.com/nishanths/license.git"
  # url "https://github.com/jfoster/license/archive/v1.0.0.tar.gz"
  # sha256 "7918b695695aa5c8489ab5838ba57cebf64d608646fc8f828b4a250ad910cf08"

  # Use the fork from jfoster, which uses platform specific data folder
  homepage "https://github.com/jfoster/license"
  url "https://github.com/jfoster/license/archive/v1.0.1.tar.gz"
  sha256 "24a3fab58b03098d4a5192c36ab668b7a680008ba336902ce5f6a65ce1b859a7"
  head "https://github.com/jfoster/license.git"

  disable! date: "2021-05-22", because: <<~EOS
    (the forked one with XDG Base Directory support) is deleted.
  EOS

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
