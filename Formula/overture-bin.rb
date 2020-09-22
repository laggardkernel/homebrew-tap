class OvertureBin < Formula
  desc "A customized DNS forwarder written in Go"
  homepage "https://github.com/shawn1m/overture"
  url "https://github.com/shawn1m/overture/releases/download/v1.6.1/overture-darwin-amd64.zip"
  sha256 "eac96e3dcda549a4d49cadd54ddc07de9fa828321d72721d7f992fe259bfdd8a"
  head "https://github.com/shawn1m/overture.git"

  bottle :unneeded

  def install
    bin.install "overture-darwin-amd64" => "overture"

    (etc/"overture").mkpath
    # etc.install "config.json" => "overture/config.json"

    # https://stackoverflow.com/questions/690794/ruby-arrays-w-vs-w
    %W[
      config.json
      domain_alternative_sample
      domain_primary_sample
      domain_ttl_sample
      hosts_sample
      ip_network_alternative_sample
      ip_network_primary_sample
    ].each do |i|
      etc.install "#{i}" => "overture/#{i}"
    end
  end

  def caveats; <<~EOS
    Caveat: HTTP port 5555 is taken by overture for debugging requests.
    If you would like to change these settings, edit the plist service file.

    Homebrew services are run as LaunchAgents by current user.
    To make overture service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "overture -c /usr/local/etc/overture/config.json"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/overture</string>
          <string>-c</string>
          <string>#{etc}/overture/config.json</string>
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
end
