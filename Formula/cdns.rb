class Cdns < Formula
  desc "Cure your poinsoned DNS with EDNS option detection"
  # homepage "https://github.com/laggardkernel/cdns"
  # head "https://github.com/laggardkernel/cdns.git"
  homepage "https://github.com/semigodking/cdns"
  url "https://github.com/semigodking/cdns/archive/release-1.1.tar.gz"
  sha256 "5455c91bc48cbc3443c2f8fa6b251b775a6239744e8e66544c0e957d3b79cc48"
  head "https://github.com/semigodking/cdns.git"
  # TODO: head failed to build.
  #  cdns_init_server(...) bind: Invalid argument

  # Caveat: HEAD still fails to be build.

  depends_on "argp-standalone" => :build
  depends_on "cmake" => :build

  def install
    if build
      inreplace "blacklist.c" do |s|
        s.gsub! "tdestroy(ipv4_blacklist_root, _blacklist_freenode);",
                "// tdestroy(ipv4_blacklist_root, _blacklist_freenode);"
      end

      # # Another solution for the endian.h problem on macOS
      # # Since we changed CFLAGS, this is not needed.
      # # https://stackoverflow.com/q/20813028/5101148
      # inreplace "dns.h" do |s|
      #   s.gsub! "#include <endian.h>",
      #           "#include <machine/endian.h>"
      # end
    end

    ENV.append "CFLAGS", "-I/usr/local/include -L/usr/local/lib -I/usr/include/machine -largp"
    mkdir "build" do
      system "cmake", *std_cmake_args, ".."
      system "make", "install", "PREFIX=#{prefix}"
    end

    inreplace "config.json.example" do |s|
      s.gsub! '"daemon": true', '"daemon": false'
      s.gsub! '"log": "syslog:daemon"', '"log": "stderr"'
      s.gsub! '"listen_port": 1053', '"listen_port": 5355'
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
  end

  def caveats
    <<~EOS
      It's not recommended to run cdns alone. A forwarding DNS server
      with cache support, like dnsmasq or unbound, should be put before it.

      CureDNS runs on localhost (127.0.0.1), port 5355 by default.
      If you would like to change these settings, edit the plist service file.

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
