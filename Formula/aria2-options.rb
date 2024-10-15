class Aria2Options < Formula
  desc "Aria2 with hidden identity (metalink support disabled)"
  homepage "https://aria2.github.io/"
  license "GPL-2.0-or-later"

  stable do
    version "1.37.0"
    url "https://github.com/aria2/aria2/releases/download/release-#{version}/aria2-#{version}.tar.xz"
  end

  head do
    url "https://github.com/aria2/aria2.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-openssl", "Build with openssl support"
  option "with-gnutls", "Build with gnutls support"

  conflicts_with "aria2", because: "they are variants of the same package"

  if build.with?("gnutls") || build.with?("openssl")
    # https://github.com/macports/macports-ports/commit/fc9881bfc1ac70283f273272f5263fe70ec2d509
    patch :DATA
  end

  # rubocop: disable all
  depends_on "c-ares" if build.with? "c-ares"
  depends_on "gnutls" if build.with? "gnutls"
  depends_on "libssh2"
  depends_on "openssl@3" if build.with? "openssl"
  depends_on "pkg-config" => :build
  depends_on "sqlite"
  # rubocop: enable all

  # libxml2 is preferred over expat
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "gettext"
  end

  def install
    ENV.cxx11

    ### Hide identity
    # Remove Wawnt-Digest: src/HttpRequest.cc Line 250
    inreplace "src/HttpRequest.cc", "if (!noWantDigest_)", "if (false)"

    # Remove default metalink accept header: build wit --disable-metalink
    # Accept: */*,application/metalink4+xml,application/metalink+xml
    # inreplace "src/HttpRequest.cc", "if (acceptMetalink_)", "if (false)"
    # Remove default header when metalink is disabled: Accept: */*
    # inreplace "src/HttpRequest.cc", 'builtinHds.emplace_back("Accept:", acceptTypes);',
    #   '// builtinHds.emplace_back("Accept:", acceptTypes);'

    # Remove the limit of max-connection-per-server
    # https://github.com/aria2/aria2/pull/1431/files
    inreplace "src/OptionHandlerFactory.cc", ", 1, 16, ", ", 1, -1, "

    args = %w[
      --disable-silent-rules
      --with-libssh2
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
    ]

    args << "--with-libcares" if build.with? "c-ares"

    # aria2 doesn't use the system default CA cert.
    #  https://github.com/aria2/aria2/issues/1636
    if build.with? "gnutls"
      args << "--with-gnutls"
      args << "--without-appletls"
      args << "--without-openssl"
    elsif build.with? "openssl"
      # WARN: aria2 built with openssl has problem with some certs.
      # protocol error: https://github.com/aria2/aria2/issues/1494
      args << "--with-openssl"
      # ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@3"].opt_lib}/pkgconfig"
      args << "--with-openssl-prefix=#{Formula["openssl@3"].opt_prefix}"
      args << "--without-appletls"
      args << "--without-gnutls"
    else
      args << "--with-appletls"
      args << "--without-openssl"
      args << "--without-gnutls"
    end

    system "autoreconf", "-fiv" if build.head?
    system "./configure", *args, *std_configure_args
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
    system bin/"aria2c", "https://brew.sh/"
    assert_predicate testpath/"index.html", :exist?, "Failed to create index.html!"
  end
end

# Ref
# https://github.com/Homebrew/homebrew-core/pull/32328
# - http://aria2.github.io/manual/en/html/README.html#dependency

__END__
diff -u -p -r a/src/SimpleRandomizer.cc b/src/SimpleRandomizer.cc
--- a/src/SimpleRandomizer.cc	2023-11-15 03:46:08
+++ b/src/SimpleRandomizer.cc	2023-11-15 15:57:52
@@ -41,9 +41,9 @@
 #include <cstring>
 #include <iostream>

-#ifdef __APPLE__
+/*#ifdef __APPLE__
 #  include <Security/SecRandom.h>
-#endif // __APPLE__
+#endif // __APPLE__*/

 #ifdef HAVE_LIBGNUTLS
 #  include <gnutls/crypto.h>
@@ -106,9 +106,9 @@
     assert(r);
     abort();
   }
-#elif defined(__APPLE__)
+/*#elif defined(__APPLE__)
   auto rv = SecRandomCopyBytes(kSecRandomDefault, len, buf);
-  assert(errSecSuccess == rv);
+  assert(errSecSuccess == rv); */
 #elif defined(HAVE_LIBGNUTLS)
   auto rv = gnutls_rnd(GNUTLS_RND_RANDOM, buf, len);
   if (rv != 0) {
