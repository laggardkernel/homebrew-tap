class Tachidesk < Formula
  desc "Rewrite of Tachiyomi for the Desktop"
  homepage "https://github.com/Suwayomi/Tachidesk-Server"
  version "0.6.5-r1122"
  url "https://github.com/Suwayomi/Tachidesk-Server/releases/download/v#{version.to_s.split("-").first}/Tachidesk-Server-v#{version}.jar"
  license "MPL-2.0"
  revision 1

  livecheck do
    url "https://github.com/Suwayomi/Tachidesk-Server/releases"
    # .jar is hidden in folded "Show all * assets"
    regex(%r{href="[^"]+?/releases/download/[^/]+/Tachidesk-Server-v?(\d+(?:\.\d+)+-?[^">]*?)-mac[^"]+["' >]}i)
    strategy :page_match do |page|
      page.scan(regex).map { |match| match&.first }
    end
  end

  def pkg_name
    "tachidesk"
  end

  def bin_name
    "Tachidesk-Server"
  end

  def install
    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install pkg_name.to_s

    (buildpath/"tachidesk").write <<~EOS
      #!/bin/sh
      java -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    (buildpath/"tachidesk-debug").write <<~EOS
      #!/bin/sh
      java -Dsuwayomi.tachidesk.config.server.debugLogsEnabled=true -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install Dir["tachidesk*"]

    prefix.install_metafiles
  end

  def post_install
    (var/"log/#{pkg_name}").mkpath
    chmod 0755, var/"log/#{pkg_name}"
  end

  def caveats
    <<~EOS
      Tachidesk-Server depends on Java 8+. Please install an available JDK manually.
      Note: Tachidesk-Server listens at 0.0.0.0:4567 by default.
      Default settings is generated automatically at first run into
        ~/Library/Application Support/Tachidesk/server.conf
      https://github.com/Suwayomi/Tachidesk-Server/wiki/Configuring-Tachidesk-Server
    EOS
  end

  service do
    run %W[
      /usr/bin/java
      -Dsuwayomi.tachidesk.config.server.systemTrayEnabled=false
      -Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false
      -jar
      #{opt_prefix}/share/tachidesk/Tachidesk-Server.jar
    ]
    keep_alive true
    log_path var/"log/tachidesk/tachidesk.log"
    error_log_path var/"log/tachidesk/tachidesk.log"
  end
end
