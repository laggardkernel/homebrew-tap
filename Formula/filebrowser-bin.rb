class FilebrowserBin < Formula
  desc "Web File Browser"
  homepage "https://github.com/filebrowser/filebrowser"
  version "2.14.1"
  url "https://github.com/filebrowser/filebrowser/releases/download/v#{version}/darwin-amd64-filebrowser.tar.gz"
  sha256 "791e2d8711e5deae10b08e242d87bf962eecbe2dde45760bd362a9561b785fa3"

  bottle :unneeded

  conflicts_with "filebrowser", :because => "same package"

  def install
    Dir.glob(["filebrowser*"]).each do |dst|
      bin.install "#{dst}" => "filebrowser"
    end

    share_dst = "#{prefix}/share/filebrowser"
    mkdir_p "#{share_dst}"
    config_path = etc/"filebrowser"

    # https://github.com/filebrowser/filebrowser/blob/master/.docker.json
    root_dir = ENV["USER"]
    root_dir = "/Users/#{root_dir}"
    (buildpath/".filebrowser.json").write <<~EOS
      {
        "port": 8080,
        "baseURL": "",
        "address": "localhost",
        "log": "stdout",
        "database": "#{config_path}/filebrowser.db",
        "root": "#{root_dir}"
      }
    EOS

    # Save a copy of default config into share
    cp ".filebrowser.json", "#{share_dst}/"

    # Install/move conf into etc
    [".filebrowser.json"].each do |dst|
      dst_default = config_path/"#{dst}.default"
      rm dst_default if dst_default.exist?
      config_path.install dst
    end
  end

  def post_install
    (var/"log/filebrowser").mkpath
    chmod 0755, var/"log/filebrowser"
  end

  def caveats; <<~EOS
    By default, filebrowser listens on localhost:8080 with auth
      username: admin
      password: admin

    Check detail usage at https://filebrowser.org/
  EOS
  end

  # #{etc} is not supported here
  plist_options :manual => "filebrowser -c /usr/local/etc/filebrowser/.filebrowser.json"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/filebrowser</string>
        <string>-c</string>
        <string>#{etc}/filebrowser/.filebrowser.json</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{etc}/filebrowser</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/filebrowser/filebrowser.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/filebrowser/filebrowser.log</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <dict>
        <key>SuccessfulExit</key>
        <false/>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/filebrowser", "version"
  end
end
