class OvertureBin < Formula
  desc "A customized DNS forwarder written in Go"
  homepage "https://github.com/shawn1m/overture"
  version "1.7"
  url "https://github.com/shawn1m/overture/releases/download/v#{version}/overture-darwin-amd64.zip"
  sha256 "4e59ed4557c05825130937cfd3c18a7510910f5b2bf0561c4db2c66e7ab81ee2"
  head "https://github.com/shawn1m/overture.git"
  license "MIT"

  livecheck do
    url "https://github.com/shawn1m/overture/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  bottle :unneeded

  def install
    bin.install "overture-darwin-amd64" => "overture"

    config_path = etc/"overture"
    config_path.mkpath
    # etc.install "config.yml" => "overture/config.yml"

    # https://stackoverflow.com/questions/690794/ruby-arrays-w-vs-w
    # %W[
    #   domain_alternative_sample
    #   domain_primary_sample
    #   domain_ttl_sample
    #   hosts_sample
    #   ip_network_alternative_sample
    #   ip_network_primary_sample
    # ].each do |dst|
    Dir.glob(["*_sample"]).each do |dst|
      # etc.install "#{dst}" => "overture/#{dst}"
      config_path.install dst
    end

    Dir.glob(["*.yml", "*.yaml"]).each do |dst|
      dst_default = config_path/"#{dst}.default"
      rm dst_default if dst_default.exist?
      config_path.install dst
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
          <string>#{etc}/overture/config.yml</string>
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
