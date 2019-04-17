class Nghttp2 < Formula
  desc "HTTP/2 C Library"
  homepage "https://nghttp2.org/"
  url "https://github.com/nghttp2/nghttp2/releases/download/v1.37.0/nghttp2-1.37.0.tar.xz"
  sha256 "aa090b164b17f4b91fe32310a1c0edf3e97e02cd9d1524eef42d60dd1e8d47b7"

  bottle do
    sha256 "336eb6bf2788bcf43c47e40d31e20af00685695baa74a821e4fd5bf5485bf48d" => :mojave
    sha256 "c4b73515d2c207657f4d8a69b64f772d51208d069ae1f0cbd005f6d287d979f8" => :high_sierra
    sha256 "e8d38af114792011b03827d512ddf9a1f9c2fe48c641f18e04bbc00d94277057" => :sierra
  end

  head do
    url "https://github.com/nghttp2/nghttp2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-openssl@1.1", "Build with OpenSSL 1.1"
  option "with-python", "Build with Python3 bindings"

  deprecated_option "with-python3" => "with-python"

  depends_on "cunit" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build
  depends_on "c-ares"
  depends_on "jansson"
  depends_on "jemalloc"
  depends_on "libev"
  depends_on "libevent"
  if build.with?("openssl@1.1")
    depends_on "openssl@1.1"
  else
    depends_on "openssl"
  end
  depends_on "python" => :optional

  def install

    ENV.cxx11

    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-app
      --disable-python-bindings
      --with-xml-prefix=/usr
    ]

    # requires thread-local storage features only available in 10.11+
    args << "--disable-threads" if MacOS.version < :el_capitan

    if build.with?("openssl@1.1")
      # https://github.com/nghttp2/nghttp2/issues/291
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      ENV.prepend_path "OPENSSL_CFLAGS", "-I#{Formula["openssl@1.1"].opt_include}"
      ENV.prepend_path "OPENSSL_LIBS", "-L#{Formula["openssl@1.1"].opt_lib} -lssl -lcrypto"
    end

    system "autoreconf", "-ivf" if build.head?
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"

    if build.with? "python"
      pyver = Language::Python.major_minor_version "python3"
      ENV["PYTHONPATH"] = cythonpath = buildpath/"cython/lib/python#{pyver}/site-packages"
      cythonpath.mkpath
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{pyver}/site-packages"

      resource("Cython").stage do
        system "python3", *Language::Python.setup_install_args(buildpath/"cython")
      end

      cd "python" do
        system buildpath/"cython/bin/cython", "nghttp2.pyx"
        system "python3", *Language::Python.setup_install_args(prefix)
      end
    end
  end

  test do
    system bin/"nghttp", "-nv", "https://nghttp2.org"
  end
end
