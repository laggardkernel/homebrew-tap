class DnsmasqOptions < Formula
  desc "Lightweight DNS forwarder and DHCP server"
  homepage "http://www.thekelleys.org.uk/dnsmasq/doc.html"
  url "https://www.thekelleys.org.uk/dnsmasq/dnsmasq-2.85.tar.gz"
  sha256 "f36b93ecac9397c15f461de9b1689ee5a2ed6b5135db0085916233053ff3f886"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]

  livecheck do
    url "http://www.thekelleys.org.uk/dnsmasq/"
    regex(/href=.*?dnsmasq[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 1
    sha256 arm64_big_sur: "a5dff893836bb30d9dd1b2ae17a3b5c57936a570014babd188d6d6935fb8cd25"
    sha256 big_sur:       "d277d696e1432881e4bbbc0d68443fbdec125d0dd83c9041d5d58bcab0acae5e"
    sha256 catalina:      "945ab265756b63a2040d5bdcc4f8c2c24e379d60ed2e21249b77eade885630ff"
    sha256 mojave:        "6054ac54814f919df6733c9f8180444b3b199321cbb0616b5ae084afa0ceaf66"
    sha256 x86_64_linux:  "1d73f8523a27c90ba0634122bf108405523deb5ddd4b0754fcdee94341d28190"
  end

  option "with-libidn", "Compile with IDN support"
  option "with-dnssec", "Compile with DNSSEC support"

  deprecated_option "with-idn" => "with-libidn"

  depends_on "pkg-config" => :build
  depends_on "nettle" if build.with? "dnssec"
  depends_on "libidn" => :optional
  depends_on "gettext" if build.with? "libidn"

  def install
    ENV.deparallelize

    # Fix etc location
    inreplace %w[dnsmasq.conf.example src/config.h man/dnsmasq.8
                 man/es/dnsmasq.8 man/fr/dnsmasq.8].each do |s|
      s.gsub! "/var/lib/misc/dnsmasq.leases",
              var/"lib/misc/dnsmasq/dnsmasq.leases", false
      s.gsub! "/etc/dnsmasq.conf", etc/"dnsmasq.conf", false
      s.gsub! "/var/run/dnsmasq.pid", var/"run/dnsmasq/dnsmasq.pid", false
      s.gsub! "/etc/dnsmasq.d", etc/"dnsmasq.d", false
      s.gsub! "/etc/ppp/resolv.conf", etc/"dnsmasq.d/ppp/resolv.conf", false
      s.gsub! "/etc/dhcpc/resolv.conf", etc/"dnsmasq.d/dhcpc/resolv.conf", false
      s.gsub! "/usr/sbin/dnsmasq", HOMEBREW_PREFIX/"sbin/dnsmasq", false
    end

    # Optional IDN support
    if build.with? "libidn"
      inreplace "src/config.h", "/* #define HAVE_IDN */", "#define HAVE_IDN"
      ENV.append_to_cflags "-I#{Formula["gettext"].opt_include}"
      ENV.append "LDFLAGS", "-L#{Formula["gettext"].opt_lib} -lintl"
    end

    # Optional DNSSEC support
    if build.with? "dnssec"
      inreplace "src/config.h", "/* #define HAVE_DNSSEC */", "#define HAVE_DNSSEC"
      inreplace "dnsmasq.conf.example" do |s|
        s.gsub! "#conf-file=%%PREFIX%%/share/dnsmasq/trust-anchors.conf",
                "conf-file=#{opt_pkgshare}/trust-anchors.conf"
        s.gsub! "#dnssec", "dnssec"
      end
    end

    # Fix compilation on newer macOS versions.
    ENV.append_to_cflags "-D__APPLE_USE_RFC_3542"

    inreplace "Makefile" do |s|
      s.change_make_var! "CFLAGS", ENV.cflags
      s.change_make_var! "LDFLAGS", ENV.ldflags
    end

    if build.with? "libidn"
      system "make", "install-i18n", "PREFIX=#{prefix}"
    else
      system "make", "install", "PREFIX=#{prefix}"
    end

    pkgshare.install "trust-anchors.conf" if build.with? "dnssec"
    etc.install "dnsmasq.conf.example" => "dnsmasq.conf"
  end

  def post_install
    (var/"lib/misc/dnsmasq").mkpath
    (var/"run/dnsmasq").mkpath
    (etc/"dnsmasq.d/ppp").mkpath
    (etc/"dnsmasq.d/dhcpc").mkpath
  end

  def caveats; <<~EOS
    To configure dnsmasq, take the default example configuration at
      #{etc}/dnsmasq.conf and edit to taste.
  EOS
  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/dnsmasq</string>
          <string>--keep-in-foreground</string>
          <string>-C</string>
          <string>#{etc}/dnsmasq.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    system "#{sbin}/dnsmasq", "--test"
  end
end
