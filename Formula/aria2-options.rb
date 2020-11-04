# ref
# - http://aria2.github.io/manual/en/html/README.html#dependency
class Aria2Options < Formula
  desc "aria2 with hidden identity (metalink support disabled)"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.xz"
  sha256 "1e2b7fd08d6af228856e51c07173cfcf987528f1ac97e04c5af4a47642617dfd"
  license "GPL-2.0"

  conflicts_with "aria2", :because => "both install binaries `aria2c`"

  # option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-openssl", "Build with openssl support"
  option "with-gnutls", "Build with gnutls support"

  depends_on "pkg-config" => :build
  depends_on "libssh2"
  depends_on "c-ares"
  depends_on "openssl@1.1" if build.with? "openssl"
  depends_on "gnutls" if build.with? "gnutls"

  uses_from_macos "libxml2"  # libxml2 is preferred over expat
  uses_from_macos "zlib"

  def install
    ENV.cxx11

    # Hide identity
    # src/HttpRequest.cc Line 250
    # Wawnt-Digest
    inreplace "src/HttpRequest.cc", "if (!noWantDigest_)", "if (false)"
    # Accept
    # headers for metalink, --disable-metalink
    # inreplace "src/HttpRequest.cc", "if (acceptMetalink_)", "if (false)"
    # inreplace "src/HttpRequest.cc", 'builtinHds.emplace_back("Accept:", acceptTypes);', '// builtinHds.emplace_back("Accept:", acceptTypes);'

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-libgmp
      --without-libgcrypt
      --with-libcares
      --with-libssh2
    ]

    if build.with? "gnutls"
      args << "--with-gnutls"
      args << "--with-ca-bundle=#{etc}/gnutls/cert.pem"
      args << "--without-appletls"
      args << "--without-openssl"
    elsif build.with? "openssl"
      # TODO: fix openssl build
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      # args << "--with-openssl=#{Formula["openssl@1.1"].opt_prefix}"  # not work
      args << "--with-openssl"
      args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
      args << "--without-appletls"
      args << "--without-gnutls"
      args << "--without-libnettle"
    else
      args << "--with-appletls"
      args << "--without-openssl"
      args << "--without-gnutls"
      args << "--without-libnettle"
    end

    system "./configure", *args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system "#{bin}/aria2c", "https://brew.sh/"
    assert_predicate testpath/"index.html", :exist?, "Failed to create index.html!"
  end
end
