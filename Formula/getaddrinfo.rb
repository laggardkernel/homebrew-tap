class Getaddrinfo < Formula
  desc "Script to resolve domain to IP address with OS's getaddrinfo() API"
  homepage "https://github.com/acdha/unix_tools"
  version "812fce8"
  url "https://raw.githubusercontent.com/acdha/unix_tools/#{version}/bin/getaddrinfo"
  # sha256 ""

  # Add short options and fix limit for multiple hostnames
  patch :DATA

  livecheck do
    url "https://github.com/acdha/unix_tools/commits/master/bin/getaddrinfo"
    regex(%r{href="/acdha/unix_tools/tree/([a-z0-9]{7,}+)" })
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  def install
    bin.install "getaddrinfo"
  end

  test do
    system bin/"getaddrinfo", "--help"
  end
end

__END__
--- a/getaddrinfo
+++ b/getaddrinfo
@@ -30,2 +30,3 @@
 parser.add_argument(
+    "-H",
     "--show-hostname",
@@ -36,2 +36,3 @@
 parser.add_argument(
+    "-l",
     "--limit",
@@ -82,1 +82,1 @@
-            raise SystemExit
+            break
