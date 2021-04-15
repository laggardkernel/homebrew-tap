class Aria2Options < Formula
  desc "aria2 with hidden identity (metalink support disabled)"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.xz"
  sha256 "1e2b7fd08d6af228856e51c07173cfcf987528f1ac97e04c5af4a47642617dfd"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://github.com/aria2/aria2/releases/latest"
    regex(%r{href=.*?/tag/release[._-]?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end
  
  bottle :unneeded

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

    ### Hide identity
    # Remove Wawnt-Digest: src/HttpRequest.cc Line 250
    inreplace "src/HttpRequest.cc", "if (!noWantDigest_)", "if (false)"

    # Remove default metalink accept header: build wit --disable-metalink
    # Accept: */*,application/metalink4+xml,application/metalink+xml
    # inreplace "src/HttpRequest.cc", "if (acceptMetalink_)", "if (false)"
    # Remove default header when metalink is disabled: Accept: */*
    # inreplace "src/HttpRequest.cc", 'builtinHds.emplace_back("Accept:", acceptTypes);', '// builtinHds.emplace_back("Accept:", acceptTypes);'

    # Remove the limit of max-connection-per-server
    # https://github.com/aria2/aria2/pull/1431/files
    inreplace "src/OptionHandlerFactory.cc", ", 1, 16, ", ", 1, -1, "

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
      # aria2 failed to be built with openssl, both on Linux and macOS
      # protocol error: https://github.com/aria2/aria2/issues/1494
      args << "--with-openssl"
      # ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      args << "--with-openssl-prefix=#{Formula["openssl@1.1"].opt_prefix}"
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

# ref
# - http://aria2.github.io/manual/en/html/README.html#dependency
