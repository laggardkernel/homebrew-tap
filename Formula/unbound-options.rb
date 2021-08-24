class UnboundOptions < Formula
  desc "Validating, recursive, caching DNS resolver"
  homepage "https://www.unbound.net"
  version "1.13.2"
  url "https://nlnetlabs.nl/downloads/unbound/unbound-#{version}.tar.gz"
  # sha256 ""
  license "BSD-3-Clause"
  head "https://github.com/NLnetLabs/unbound.git"

  # We check the GitHub repo tags instead of
  # https://nlnetlabs.nl/downloads/unbound/ since the first-party site has a
  # tendency to lead to an `execution expired` error.
  livecheck do
    url :head
    regex(/^(?:release-)?v?(\d+(?:\.\d+)+)$/i)
  end

  option "with-python", "Build with Python module"

  depends_on "libevent"
  depends_on "nghttp2"
  depends_on "openssl@1.1"
  depends_on "python@3.9" if build.with? "python"
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
      ENV.prepend "LDFLAGS", `#{Formula["python@3.9"].opt_prefix}/bin/python3-config --ldflags`.chomp
      ENV.prepend "CPPFLAGS", `#{Formula["python@3.9"].opt_prefix}/bin/python3-config --cflags`.chomp
      ENV.prepend "PYTHON_VERSION", "3.9"

      args << "--with-pyunbound"
      args << "--with-pythonmodule"
      args << "PYTHON_SITE_PKG=#{lib}/python3.9/site-packages"
    end

    system "./configure", *args

    inreplace "doc/example.conf", 'username: "unbound"', 'username: "@@HOMEBREW-UNBOUND-USER@@"'
    system "make"
    # system "make", "test"
    system "make", "install"
  end

  def post_install
    conf = etc/"unbound/unbound.conf"
    return unless conf.exist?
    return unless conf.read.include?('username: "@@HOMEBREW-UNBOUND-USER@@"')

    inreplace conf, 'username: "@@HOMEBREW-UNBOUND-USER@@"',
                    "username: \"#{ENV["USER"]}\""
  end

  plist_options startup: true

  def plist
    <<~EOS
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
