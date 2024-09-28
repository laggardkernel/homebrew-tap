class MkcertCustom < Formula
  desc "Mkcert with patches"
  homepage "https://github.com/FiloSottile/mkcert"
  # rubocop: disable all
  version "1.4.4"
  url "https://github.com/FiloSottile/mkcert/archive/refs/tags/v#{version}.tar.gz"
  # rubocop: enable all
  license "BSD-3-Clause"

  head do
    url "https://github.com/FiloSottile/mkcert.git"
  end

  depends_on "go" => :build

  patch do
    url "https://github.com/FiloSottile/mkcert/pull/505.patch"
  end

  def install
    version_str = version.to_s.start_with?("HEAD") ? "HEAD" : version.to_s
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.Version=v#{version_str}")
    mv bin/name.to_s, bin/"mkcert"
    prefix.install_metafiles
  end

  test do
    ENV["CAROOT"] = testpath
    system bin/"mkcert", "brew.test"
    assert_predicate testpath/"brew.test.pem", :exist?
    assert_predicate testpath/"brew.test-key.pem", :exist?
    output = (testpath/"brew.test.pem").read
    assert_match "-----BEGIN CERTIFICATE-----", output
    output = (testpath/"brew.test-key.pem").read
    assert_match "-----BEGIN PRIVATE KEY-----", output
  end
end
