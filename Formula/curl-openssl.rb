class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.haxx.se/download/curl-7.64.1.tar.bz2"
  sha256 "4cc7c738b35250d0680f29e93e0820c4cb40035f43514ea3ec8d60322d41a45d"

  bottle do
    sha256 "44d845c366ba037c65fe913ca2bee9db03a847ba333176689fa94c6af0f935b3" => :mojave
    sha256 "0bdb433305b927f6a0c71393c0c8c5002ff6c566440b82f93d8a2d5014cdc01d" => :high_sierra
    sha256 "9dc946b3332439ca177c3ca0c01748955365d49fb47d7cb29c8c2178bb83223c" => :sierra
  end

  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  option "with-openssl@1.1", "Build with OpenSSL 1.1"

  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "c-ares"
  depends_on "libidn"
  depends_on "libmetalink"
  depends_on "libssh2"
  depends_on "nghttp2"
  depends_on "openldap"
  if build.with?("openssl@1.1")
    depends_on "openssl@1.1"
  else
    depends_on "openssl"
  end
  depends_on "rtmpdump"

  def install
    system "./buildconf" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-ares=#{Formula["c-ares"].opt_prefix}
      --with-gssapi
      --with-libidn2
      --with-libmetalink
      --with-librtmp
      --with-libssh2
    ]

    if build.with?("openssl@1.1")
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
      args << "--with-ca-path=#{etc}/openssl@1.1/certs"
      args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    else
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl"].opt_lib}/pkgconfig"
      args << "--with-ca-bundle=#{etc}/openssl/cert.pem"
      args << "--with-ca-path=#{etc}/openssl/certs"
      args << "--with-ssl=#{Formula["openssl"].opt_prefix}"
    end

    system "./configure", *args
    system "make", "install"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
