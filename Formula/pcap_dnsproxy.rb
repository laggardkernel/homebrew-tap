class PcapDnsproxy < Formula
  desc "Powerful DNS proxy designed to anti DNS spoofing"
  # homepage "https://github.com/chengr28/Pcap_DNSProxy"
  homepage "https://github.com/Lyoko-Jeremie/Pcap_DNSProxy"
  url "https://github.com/Lyoko-Jeremie/Pcap_DNSProxy/archive/v0.4.9.13.tar.gz"
  sha256 "998c32c97a8f72e9b8abc3734c57da812ff3f539f53cf758b3b2692f904c1967"
  head "https://github.com/Lyoko-Jeremie/Pcap_DNSProxy.git"

  bottle :unneeded

  depends_on :macos => :el_capitan
  depends_on :xcode => :build
  depends_on "libsodium"
  depends_on "openssl@1.1"

  def install
    (buildpath/"Source/Dependency/LibSodium").install_symlink Formula["libsodium"].opt_lib/"libsodium.a" => "LibSodium_macOS.a"
    (buildpath/"Source/Dependency/OpenSSL").install_symlink Formula["openssl@1.1"].opt_lib/"libssl.a" => "LibSSL_macOS.a"
    (buildpath/"Source/Dependency/OpenSSL").install_symlink Formula["openssl@1.1"].opt_lib/"libcrypto.a" => "LibCrypto_macOS.a"
    xcodebuild "-project", "./Source/Pcap_DNSProxy.xcodeproj", "-target", "Pcap_DNSProxy", "-configuration", "Release", "SYMROOT=build"
    bin.install "Source/build/Release/Pcap_DNSProxy"
    (etc/"pcap_dnsproxy").install Dir["Source/Auxiliary/ExampleConfig/*.{ini,txt}"]
    prefix.install "Source/Auxiliary/ExampleConfig/pcap_dnsproxy.service.plist"
  end

  plist_options :startup => true, :manual => "sudo #{HOMEBREW_PREFIX}/opt/pcap_dnsproxy/bin/Pcap_DNSProxy -c #{HOMEBREW_PREFIX}/etc/pcap_dnsproxy/"

  test do
    (testpath/"pcap_dnsproxy").mkpath
    cp Dir[etc/"pcap_dnsproxy/*"], testpath/"pcap_dnsproxy/"

    inreplace testpath/"pcap_dnsproxy/Config.ini" do |s|
      s.gsub! /^Direct Request.*/, "Direct Request = IPv4 + IPv6"
      s.gsub! /^Operation Mode.*/, "Operation Mode = Proxy"
      s.gsub! /^Listen Port.*/, "Listen Port = 9999"
    end

    pid = fork { exec bin/"Pcap_DNSProxy", "-c", testpath/"pcap_dnsproxy/" }
    begin
      system "dig", "google.com", "@127.0.0.1", "-p", "9999", "+short"
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end

# https://github.com/Homebrew/homebrew-core/pull/19121
# https://github.com/ilovezfs/homebrew-core/blob/0076ea375d848f8fe152edb58022cb4f2083fbf2/Formula/pcap_dnsproxy.rb
# https://github.com/Homebrew/homebrew-core/pull/16973
# https://github.com/Homebrew/homebrew-core/blob/b532ae4e8716f4fe8e8362667f6d15a234789cd1/Formula/pcap_dnsproxy.rb
