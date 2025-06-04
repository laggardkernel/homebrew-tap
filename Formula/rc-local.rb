class RcLocal < Formula
  desc "Emulate /etc/rc.local with launchd"
  homepage "https://salsa.debian.org/debian/rc"
  # rubocop: disable all
  version "0.1.0"
  url "https://httpbin.org/anything/rc-local-#{version}"
  # rubocop: enable all

  livecheck do
    skip "Plist service, no livecheck needed"
  end

  def install
    (buildpath/"rc.local").write <<~EOS
      #!/bin/bash
      # vim: ft=bash fdm=marker foldlevel=0 sw=2 ts=2 sts=2 et
      # Run as /Library/LaunchDaemons by root.
    EOS
    chmod 0755, buildpath/"rc.local"

    share_dst = "#{share}/rc-local"
    mkdir_p share_dst.to_s
    cp buildpath/"rc.local", "#{share_dst}/rc.local"

    dst = etc/"rc.local.default"
    rm dst if dst.exist?
    etc.install "rc.local"
  end

  def caveats
    <<~EOS
      If the service is started with `sudo brew services`. Run `brew fix-perm`
      to fix the broken file perms after rc.local executed. Like
        sudo brew services start rc-local; brew fix-perm all
    EOS
  end

  service do
    run ["#{HOMEBREW_PREFIX}/etc/rc.local"]
    keep_alive false
    launch_only_once true
    require_root true
    working_dir var/"log"
    log_path var/"log/rc.local.log"
    error_log_path var/"log/rc.local.log"
  end
end
