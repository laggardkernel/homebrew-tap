class Aria2Options < Formula
  desc "aria2 with hidden identity (metalink support disabled)"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.xz"
  sha256 "1e2b7fd08d6af228856e51c07173cfcf987528f1ac97e04c5af4a47642617dfd"
  license "GPL-2.0"

  depends_on "pkg-config" => :build
  depends_on "libssh2"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_linux do
    depends_on "openssl@1.1"
  end

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
      --with-appletls
      --with-libssh2
      --without-openssl
      --without-gnutls
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
    ]

    system "./configure", *args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system "#{bin}/aria2c", "https://brew.sh/"
    assert_predicate testpath/"index.html", :exist?, "Failed to create index.html!"
  end
end
