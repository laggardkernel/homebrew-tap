class CurlOptions < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  url "https://curl.se/download/curl-7.76.0.tar.bz2"
  sha256 "e29bfe3633701590d75b0071bbb649ee5ca4ca73f00649268bd389639531c49a"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle :unneeded

  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  option "with-brotli", "Build with lossless compression support"
  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-gssapi", "Build with GSSAPI/Kerberos authentication support"
  option "with-libidn", "Build with international domain name support"
  option "with-libmetalink", "Build with Metalink XML support"
  option "with-libssh2", "Build with scp and sftp support"
  option "with-libressl", "Build with LibreSSL instead of Secure Transport or OpenSSL"
  option "with-nghttp2", "Build with HTTP/2 support (requires OpenSSL or LibreSSL)"
  option "with-openldap", "Build with OpenLDAP support"
  option "with-openssl@1.1", "Build with OpenSSL 1.1 support"
  option "with-rtmpdump", "Build with RTMP support"

  deprecated_option "with-rtmp" => "with-rtmpdump"
  deprecated_option "with-ssh" => "with-libssh2"
  deprecated_option "with-ares" => "with-c-ares"

  # HTTP/2 support requires OpenSSL 1.0.2+ or LibreSSL 2.1.3+ for ALPN Support
  # which is currently not supported by Secure Transport (DarwinSSL).
  if MacOS.version < :mountain_lion
    depends_on "openssl@1.1"
  elsif build.with?("libressl")
    depends_on "libressl"
  else
    depends_on "openssl@1.1"
  end

  depends_on "pkg-config" => :build
  depends_on "brotli" => :optional
  depends_on "c-ares" => :optional
  depends_on "libidn" => :optional
  depends_on "libmetalink" => :optional
  depends_on "libssh2" => :optional
  depends_on "libressl" => :optional
  depends_on "nghttp2" => :optional
  depends_on "openldap" => :optional
  depends_on "rtmpdump" => :optional
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "zlib"

  def install
    # Fail if someone tries to use both SSL choices.
    # Long-term, handle conflicting options case in core code.
    if build.with?("libressl") && build.with?("openssl@1.1")
      odie <<~EOS
      --with-openssl@1.1 and --with-libressl are both specified and
      curl can only use one at a time.
      EOS
    end

    system "./buildconf" if build.head?

    # Allow to build on Lion, lowering from the upstream setting of 10.8
    ENV.append_to_cflags "-mmacosx-version-min=10.7" if MacOS.version <= :lion

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-secure-transport
    ]

    # cURL has a new firm desire to find ssl with PKG_CONFIG_PATH instead of using
    # "--with-ssl" any more. "when possible, set the PKG_CONFIG_PATH environment
    # variable instead of using this option". Multi-SSL choice breaks w/o using it.
    # ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
    if MacOS.version < :mountain_lion
      args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
      args << "--with-default-ssl-backend=openssl"
      args << "--without-libpsl"
    elsif build.with? "libressl"
      args << "--with-ssl=#{Formula["libressl"].opt_prefix}"
      args << "--with-default-ssl-backend=libressl"
    else
      args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
      args << "--with-default-ssl-backend=openssl"
      args << "--without-libpsl"
    end

    if build.with? "gssapi"
      on_macos do
        args << "--with-gssapi"
      end

      on_linux do
        args << "--with-gssapi=#{Formula["krb5"].opt_prefix}"
      end
    else
      args << "--without-gssapi"
    end

    args << (build.with?("libidn") ? "-with-libidn2" : "--without-libidn2")
    args << (build.with?("libmetalink") ? "--with-libmetalink" : "--without-libmetalink")
    args << (build.with?("libssh2") ? "--with-libssh2" : "--without-libssh2")
    args << (build.with?("rtmpdump") ? "--with-librtmp" : "--without-librtmp")

    if build.with? "c-ares"
      args << "--enable-ares=#{Formula["c-ares"].opt_prefix}"
    else
      args << "--disable-ares"
    end

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
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

# Ref
# - https://everything.curl.dev/source/build/tls
