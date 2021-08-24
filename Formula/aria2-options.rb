class Aria2Options < Formula
  desc "Aria2 with hidden identity (metalink support disabled)"
  homepage "https://aria2.github.io/"
  license "GPL-2.0-or-later"

  stable do
    version "1.36.0"
    url "https://github.com/aria2/aria2/releases/download/release-#{version}/aria2-#{version}.tar.xz"
    # sha256 ""
    depends_on "pkg-config" => :build
  end

  head do
    url "https://github.com/aria2/aria2.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
    depends_on "gettext"  => :build
  end

  # option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-openssl", "Build with openssl support"
  option "with-gnutls", "Build with gnutls support"

  depends_on "c-ares"
  depends_on "gnutls" if build.with? "gnutls"
  depends_on "libssh2"
  depends_on "openssl@1.1" if build.with? "openssl"

  # libxml2 is preferred over expat
  uses_from_macos "libxml2"
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
      --with-libcares
      --with-libssh2
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
    ]

    if build.with? "gnutls"
      args << "--with-gnutls"
      # args << "--with-ca-bundle=#{etc}/gnutls/cert.pem"
      # BUG: https://github.com/aria2/aria2/issues/1636
      args << "--with-ca-bundle=/etc/ssl/cert.pem"
      args << "--without-appletls"
      args << "--without-openssl"
    elsif build.with? "openssl"
      # WARN: aria2 built with openssl has problem with some certs.
      # protocol error: https://github.com/aria2/aria2/issues/1494
      args << "--with-openssl"
      # ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      args << "--with-openssl-prefix=#{Formula["openssl@1.1"].opt_prefix}"
      # args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
      args << "--with-ca-bundle=/etc/ssl/cert.pem"
      args << "--without-appletls"
      args << "--without-gnutls"
    else
      args << "--with-appletls"
      args << "--without-openssl"
      args << "--without-gnutls"
    end

    if build.head?
      system "autoreconf", "-fiv"
    end
    system "./configure", *args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  def caveats
    <<~EOS
    Arai2 built with openssl has problem handshaking with some certs.
    Reason unknown: https://github.com/aria2/aria2/issues/1494
    EOS
  end

  test do
    system "#{bin}/aria2c", "https://brew.sh/"
    assert_predicate testpath/"index.html", :exist?, "Failed to create index.html!"
  end
end

# Ref
# https://github.com/Homebrew/homebrew-core/pull/32328
# - http://aria2.github.io/manual/en/html/README.html#dependency
