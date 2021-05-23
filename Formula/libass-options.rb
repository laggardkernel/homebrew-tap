class LibassOptions < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  url "https://github.com/libass/libass/releases/download/0.15.1/libass-0.15.1.tar.xz"
  sha256 "1cdd39c9d007b06e737e7738004d7f38cf9b1e92843f37307b24e7ff63ab8e53"
  license "ISC"

  head do
    url "https://github.com/libass/libass.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-fontconfig", "Disable CoreText backend in favor of the more traditional fontconfig (macOS only)"

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "fribidi"
  depends_on "harfbuzz" => :recommended
  depends_on "fontconfig" => :optional

  on_linux do
    depends_on "fontconfig"
  end

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    args << "--disable-harfbuzz" if build.without? "harfbuzz"
    on_macos do
      # libass uses coretext on macOS, fontconfig on Linux
      if build.with? "fontconfig"
        args << "--disable-coretext"
      else
        args << "--disable-fontconfig"
      end
    end

    system "autoreconf", "-i" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "ass/ass.h"
      int main() {
        ASS_Library *library;
        ASS_Renderer *renderer;
        library = ass_library_init();
        if (library) {
          renderer = ass_renderer_init(library);
          if (renderer) {
            ass_renderer_done(renderer);
            ass_library_done(library);
            return 0;
          }
          else {
            ass_library_done(library);
            return 1;
          }
        }
        else {
          return 1;
        }
      }
    EOS
    system ENV.cc, "test.cpp", "-I#{include}", "-L#{lib}", "-lass", "-o", "test"
    system "./test"
  end
end
