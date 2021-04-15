class UnboundOptions < Formula
  desc "Validating, recursive, caching DNS resolver"
  homepage "https://www.unbound.net"
  url "https://nlnetlabs.nl/downloads/unbound/unbound-1.13.1.tar.gz"
  sha256 "8504d97b8fc5bd897345c95d116e0ee0ddf8c8ff99590ab2b4bd13278c9f50b8"
  license "BSD-3-Clause"
  head "https://github.com/NLnetLabs/unbound.git"

  livecheck do
    url "https://nlnetlabs.nl/downloads/unbound/"
    regex(/href=.*?unbound[._-]?(\d+(?:\.\d+)+)\S*\.t/i)
  end

  bottle :unneeded

  depends_on "libevent"
  depends_on "nghttp2"
  depends_on "openssl@1.1"
  depends_on "python" => :optional
  depends_on "swig" if build.with? "python"

  uses_from_macos "expat"

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --enable-event-api
      --enable-subnet
      --enable-tfo-client
      --enable-tfo-server
      --with-libevent=#{Formula["libevent"].opt_prefix}
      --with-libnghttp2=#{Formula["nghttp2"].opt_prefix}
      --with-ssl=#{Formula["openssl@1.1"].opt_prefix}
    ]

    on_macos do
      args << "--with-libexpat=#{MacOS.sdk_path}/usr" if MacOS.sdk_path_if_needed
    end
    on_linux do
      args << "--with-libexpat=#{Formula["expat"].opt_prefix}"
    end

    if build.with? "python"
      ENV.prepend "LDFLAGS", `#{Formula["python"].opt_prefix}/bin/python3-config --ldflags`.chomp
      ENV.prepend "PYTHON_VERSION", "3.9"

      args << "--with-pyunbound"
      args << "--with-pythonmodule"
      args << "PYTHON_SITE_PKG=#{lib}/python3.9/site-packages"
    end

    system "./configure", *args

    inreplace "doc/example.conf", 'username: "unbound"', 'username: "@@HOMEBREW-UNBOUND-USER@@"'
    system "make"
    system "make", "install"
  end

  def post_install
    conf = etc/"unbound/unbound.conf"
    return unless conf.exist?
    return unless conf.read.include?('username: "@@HOMEBREW-UNBOUND-USER@@"')

    inreplace conf, 'username: "@@HOMEBREW-UNBOUND-USER@@"',
                    "username: \"#{ENV["USER"]}\""
  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/unbound</string>
          <string>-d</string>
          <string>-c</string>
          <string>#{etc}/unbound/unbound.conf</string>
        </array>
        <key>UserName</key>
        <string>root</string>
        <key>StandardErrorPath</key>
        <string>/dev/null</string>
        <key>StandardOutPath</key>
        <string>/dev/null</string>
      </dict>
    </plist>
  EOS
  end

  test do
    system sbin/"unbound-control-setup", "-d", testpath
  end
end
