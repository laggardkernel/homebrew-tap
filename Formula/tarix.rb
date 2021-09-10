class Tarix < Formula
  desc "Tar Indexer"
  homepage "https://github.com/fastcat/tarix"
  version "1.0.9"
  url "https://github.com/fastcat/tarix/archive/refs/tags/tarix-#{version}.tar.gz"

  head do
    url "https://github.com/fastcat/tarix.git"
  end

  depends_on "glib" => :build

  patch :DATA

  def install
    # https://github.com/gromgit/homebrew-fuse/blob/main/require/macfuse.rb
    if File.exist?("#{HOMEBREW_PREFIX}/include/fuse.h") &&
       !File.symlink?("#{HOMEBREW_PREFIX}/include")
      ENV.append_path "PKG_CONFIG_PATH", HOMEBREW_LIBRARY/"Homebrew/os/mac/pkgconfig/fuse"
    end

    # setxattr declaration is not compatible with macOS fuse
    system "make", "INSTBASE=#{prefix}"
    # make install directly into #{prefix}/bin failed

    bin.install "bin/tarix"
    bin.install "bin/fuse_tarix" if File.exist? "bin/fuse_tarix"
    doc.install "QuickStart"
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      For some simple examples of how to use it, see the
      #{HOMEBREW_PREFIX}/share/doc/tarix/QuickStart
    EOS
  end

  test do
    system "#{bin}/tarix", "-h"
  end
end
__END__
diff --git a/src/fuse_rofs.c b/src/fuse_rofs.c
index 34fe8b8..a5db246 100644
--- a/src/fuse_rofs.c
+++ b/src/fuse_rofs.c
@@ -53,10 +53,17 @@ static int tarix_write(const char *path, const char *buf, size_t size,
   return -EROFS;
 }

-static int tarix_setxattr(const char *path, const char *name,
-    const char *value, size_t size, int flags) {
-  return -EROFS;
-}
+#ifdef __APPLE__
+    static int tarix_setxattr(const char *path, const char *name,
+        const char *value, size_t size, int flags, uint32_t position) {
+    return -EROFS;
+    }
+#else
+    static int tarix_setxattr(const char *path, const char *name,
+        const char *value, size_t size, int flags) {
+    return -EROFS;
+    }
+#endif

 static int tarix_create(const char *path, mode_t mode,
     struct fuse_file_info *fi) {

