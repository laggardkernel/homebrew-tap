class Cdns < Formula
  desc "Cure your poinsoned DNS with EDNS option detection"
  homepage "https://github.com/semigodking/cdns"
  # HEAD only, no regular release
  version "1.1"
  url "https://github.com/semigodking/cdns/archive/release-#{version}.tar.gz"
  # sha256 ""
  license "Apache-2.0"
  revision 1
  head "https://github.com/semigodking/cdns.git"

  depends_on "argp-standalone" => :build
  depends_on "cmake" => :build
  # Makefile: LIBS := -levent -lm -largp
  # /usr/lib/libm.dylib
  # TODO: the static build makes on sense, still depends on libevent dynamically.
  depends_on "libevent"

  def install
    # TODO: backport static build on stable version, remove in next release
    if build.stable?
      inreplace "Makefile" do |s|
        s.gsub! '$(CC) -o $@ $(CFLAGS) $^ $(LIBS)',
          "$(CC) -o $@ $(CFLAGS) $^ $(LIBS)\n	$(CC) -static -static-libgcc -s -o $@-static $(CFLAGS) $^ $(LIBS)"
      end
    end

    if OS.mac?
      # TODO: head failed to run: cdns_init_server(...) bind: Invalid argument
      if build.head?
        version_str = version.to_s.start_with?("HEAD") ? version.to_s : "v#{version}"
        inreplace "main.c" do |s|
          s.gsub!(/cdns - version:.+?\\n/, format('cdns - version: %s\n', version_str))
        end
      end

      inreplace "Makefile" do |s|
        s.gsub! "-static -static-libgcc", "-Bstatic"
      end

      inreplace "blacklist.c" do |s|
        s.gsub! "tdestroy(ipv4_blacklist_root, _blacklist_freenode);",
                "// tdestroy(ipv4_blacklist_root, _blacklist_freenode);"
      end

      ENV.prepend "CFLAGS", "-I#{HOMEBREW_PREFIX}/include -I/usr/include/machine"
      # CFLAGS used in Makefile, pass LDFLAGS with CFLAGS
      ENV.append "CFLAGS", "-L#{HOMEBREW_PREFIX}/lib"
      # # Another solution for the endian.h problem on macOS
      # # Since we changed CFLAGS, this is not needed.
      # # https://stackoverflow.com/q/20813028/5101148
      # inreplace "dns.h" do |s|
      #   s.gsub! "#include <endian.h>",
      #           "#include <machine/endian.h>"
      # end
    end

    # if build.head?
    #   system "cmake", *std_cmake_args, ".."
    #   system "make", "install", "PREFIX=#{prefix}"
    # end
    system "make"
    bin.install "cdns"
    bin.install "cdns-static"

    inreplace "config.json.example" do |s|
      s.gsub! '"daemon": true', '"daemon": false'
      s.gsub! '"log": "syslog:daemon"', '"log": "stderr"'
      # s.gsub! '"listen_port": 1053', '"listen_port": 5355'
      s.gsub! '"ip_port": "203.80.96.10"', '"ip_port": "8.8.4.4:53"'
    end

    share_dst = "#{share}/cdns"
    mkdir_p share_dst
    cp "config.json.example", "#{share_dst}/config.json"

    etc_dst = "#{prefix}/etc/cdns"
    mkdir_p etc_dst
    cp_r Dir["#{share_dst}/*"], etc_dst

    etc.install etc_dst
    # equivalent to
    # etc.install "#{etc_dst}/"
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      It's not recommended to run cdns alone. A forwarding DNS server
      with cache support, like dnsmasq or unbound, should be put before it.

      CureDNS runs on localhost (127.0.0.1), port 1053 by default.
      If you would like to change these settings, edit the config file.

        #{etc}/cdns/config.json
    EOS
  end

  plist_options manual: "cdns -c #{HOMEBREW_PREFIX}/etc/cdns/config.json"
  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/cdns</string>
            <string>-c</string>
            <string>#{etc}/cdns/config.json</string>
          </array>
          <key>KeepAlive</key>
          <dict>
            <key>SuccessfulExit</key>
            <false/>
          </dict>
          <key>RunAtLoad</key>
          <true/>
        </dict>
      </plist>
    EOS
  end

  test do
    system bin/"cdns", "--help"
  end
end
# https://github.com/semigodking/cdns/issues/15
