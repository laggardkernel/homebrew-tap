class Cdns < Formula
  desc "Cure your poinsoned DNS with EDNS option detection"
  homepage "https://github.com/semigodking/cdns"
  # rubocop: disable all
  version "1.1"
  url "https://github.com/semigodking/cdns/archive/release-#{version}.tar.gz"
  # rubocop: enable all
  license "Apache-2.0"
  revision 2
  head "https://github.com/semigodking/cdns.git"

  # livecheck do
  #   url "https://github.com/semigodking/cdns/commits"
  #   regex(%r{href="/semigodking/cdns/tree/([a-z0-9]{7,}+)" }i)
  #   strategy :page_match do |page, regex|
  #     # Only return the 1st commit to avoid alphabetical version comparison
  #     page.scan(regex).flatten.first&.slice!(0..6)
  #   end
  # end

  depends_on "cmake" => :build
  # Makefile: LIBS := -levent -lm -largp
  depends_on "argp-standalone" if OS.mac?
  depends_on "libevent"
  # -lm: /usr/lib/libm.dylib

  def install
    if version.to_s.start_with?("HEAD") || !version.to_s.match?(/^(\d+(?:\.\d+)+)$/)
      inreplace "main.c" do |s|
        s.gsub!(/cdns - version:.+?\\n/, format('cdns - version: %s\n', version.to_s))
      end
    end
    if OS.mac?
      inreplace "blacklist.c" do |s|
        s.gsub! "tdestroy(ipv4_blacklist_root, _blacklist_freenode);",
                "// tdestroy(ipv4_blacklist_root, _blacklist_freenode);"
      end
      # # static build in Makefile makes no sense, libevent still used dynamically.
      # inreplace "Makefile" do |s|
      #   s.gsub! "-static -static-libgcc", "-Bstatic"
      # end
      # https://stackoverflow.com/q/20813028/5101148
      inreplace "dns.h" do |s|
        s.gsub! "#include <endian.h>",
                "#include <machine/endian.h>"
      end
    end
    # TODO: the IPv6 listening support is completely broken, don't use it.
    # e.g. cdns_init_server(...) bind: Invalid argument
    # inreplace "cdns.c" do |s|
    #   s.gsub! "error = bind(fd, (struct sockaddr*)&addr, sizeof(addr));",
    #           <<'EOS'.chomp
    # socklen_t addr_len;
    # if (addr.ss_family == AF_INET6) {
    #   addr_len = sizeof(struct sockaddr_in6);
    # } else {
    #   addr_len = sizeof(struct sockaddr_in);
    # }
    # error = bind(fd, (struct sockaddr*)&addr, addr_len);
    # EOS
    # end

    args = %w[
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    ]
    args << "-DCMAKE_EXE_LINKER_FLAGS=-largp" if OS.mac?
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace "config.json.example" do |s|
      s.gsub! '"daemon": true', '"daemon": false'
      s.gsub! '"log": "syslog:daemon"', '"log": "stderr"'
      # s.gsub! '"listen_port": 1053', '"listen_port": 5355'
      s.gsub! '"ip_port": "203.80.96.10"', '"ip_port": "8.8.4.4:53"'
    end

    share_dst = "#{share}/cdns"
    mkdir_p share_dst
    cp "config.json.example", "#{share_dst}/config.json"

    config_temp = buildpath/"build"
    config_path = etc/"cdns"
    cp "config.json.example", config_temp/"config.json"
    Dir.chdir(config_temp.to_s) do
      %w[config.json].each do |f|
        dst_default = config_path/"#{f}.default"
        rm dst_default if dst_default.exist?
        config_path.install f
      end
    end

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

  service do
    run [opt_bin/"cdns", "-c", etc/"cdns/config.json"]
    keep_alive successful_exit: true
  end

  test do
    system bin/"cdns", "--help"
  end
end
# https://github.com/semigodking/cdns/issues/15
