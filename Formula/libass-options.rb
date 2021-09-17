class LibassOptions < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  version "0.15.2"
  url "https://github.com/libass/libass/releases/download/#{version}/libass-#{version}.tar.xz"
  # sha256 ""
  license "ISC"

  head do
    url "https://github.com/libass/libass.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only "libass with option support conflicts with the homebrew-core one"

  option "with-fontconfig", "Disable CoreText backend in favor of the more traditional fontconfig (macOS only)"

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "harfbuzz"
  depends_on "fontconfig" => :optional

  on_linux do
    depends_on "fontconfig"
  end

  def install
    system "autoreconf", "-i" if build.head?
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    # libass uses coretext on macOS, fontconfig on Linux
    on_macos do
      args << if build.with? "fontconfig"
        "--disable-coretext"
      else
        "--disable-fontconfig"
      end
    end

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<~EOS
      '--with-fontconfig' disables CoreText backend in favor of the more traditional
      fontconfig (default on linuxbrew). The difference is, libass with CoreText
      backend uses font's "FullName" to search the font, while libass with fontconfig
      backend uses "PostScriptName". Taking font "方正准圆" for example, the FullName
      is "方正准圆_GBK" and PostScriptName is "FZY3K--GBK1-0".
      Obviously, for any fansub, FullName is preferred over PostScriptName.

      The problem is 'libass' in homebrew-core is compiled with CoreText for macOS.
      The same happens with the 'libass' library used by IINA.

      References

      - https://github.com/iina/iina/issues/2711
    EOS
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
