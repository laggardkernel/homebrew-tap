class OpenvpnService < Formula
  desc "Custom launchd file for OpenVPN 2.x with log file enabled"
  homepage "https://openvpn.net/community/"
  # rubocop: disable all
  version "0.1.0"
  url "file:///dev/null"
  # rubocop: enable all

  livecheck do
    skip "Plist service, no livecheck needed"
  end

  depends_on "openvpn"

  def install
    touch "placeholder"
    share.install "placeholder"
  end

  def post_install
    (var/"log/openvpn").mkpath
    chmod 0755, var/"log/openvpn"
  end

  def caveats
    <<~EOS
      If the service is started with `sudo brew services`. Run `brew fix-perm`
      to fix the broken file perms after services started.
        sudo brew services start openvpn-service; brew fix-perm all
    EOS
  end

  service do
    run ["#{HOMEBREW_PREFIX}/sbin/openvpn", "--config", etc/"openvpn/openvpn.conf"]
    keep_alive true
    require_root true
    working_dir etc/"openvpn"
    log_path var/"log/openvpn/openvpn.log"
    error_log_path var/"log/openvpn/openvpn.log"
  end

  test do
    system sbin/"openvpn", "--show-ciphers"
  end
end
