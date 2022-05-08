class CurlOptions < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  version "7.83.0"
  url "https://curl.se/download/curl-#{version}.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-#{version.to_s.gsub('.', '_')}/curl-#{version}.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-#{version}.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-#{version}.tar.bz2"
  # sha256 ""
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-openssl", "Build with OpenSSL support"
  option "with-gnutls", "Build with GnuTLS support"

  deprecated_option "with-ares" => "with-c-ares"
  deprecated_option "with-openssl@1.1" => "with-openssl"

  # HTTP/2 support requires OpenSSL 1.0.2+ or LibreSSL 2.1.3+ for ALPN Support
  # which is currently not supported by Secure Transport (DarwinSSL).
  if build.with?("gnutls")
    depends_on "gnutls"
  else
    depends_on "openssl@1.1"
  end

  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "libidn2"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on "openldap"
  depends_on "rtmpdump"
  depends_on "zstd"
  depends_on "brotli" => :optional
  depends_on "c-ares" => :optional
  depends_on "gnutls" => :optional

  uses_from_macos "krb5"
  uses_from_macos "zlib"

  def install
    # Fail if someone tries to use both SSL choices.
    # Long-term, handle conflicting options case in core code.
    if build.with?("openssl") && build.with?("gnutls")
      odie <<~EOS
        --with-openssl and --with-gnutls are both specified and
        curl can only use one at a time.
      EOS
    end

    system "./buildconf" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-secure-transport
      --with-libidn2
      --with-librtmp
      --with-libssh2
      --without-libpsl
    ]

    args << if OS.mac?
      "--with-gssapi"
    else
      "--with-gssapi=#{Formula["krb5"].opt_prefix}"
    end

    # cURL has a new firm desire to find ssl with PKG_CONFIG_PATH instead of using
    # "--with-ssl" any more. "when possible, set the PKG_CONFIG_PATH environment
    # variable instead of using this option". Multi-SSL choice breaks w/o using it.
    # ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
    if build.with? "gnutls"
      args << "--with-gnutls=#{Formula["gnutls"].opt_prefix}"
      args << "--with-default-ssl-backend=gnutls"
    else
      args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
      args << "--with-default-ssl-backend=openssl"
    end

    args << if build.with? "c-ares"
      "--enable-ares=#{Formula["c-ares"].opt_prefix}"
    else
      "--disable-ares"
    end

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
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

# Ref
# - https://everything.curl.dev/source/build/tls
# - https://github.com/Homebrew/homebrew-core/pull/58274
