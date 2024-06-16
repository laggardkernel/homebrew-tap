class Suwayomi < Formula
  desc "Rewrite of Tachiyomi for the Desktop"
  homepage "https://github.com/Suwayomi/Suwayomi-Server"
  version "1.1.1-r1535"
  url "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v#{version.to_s.split("-").first}/Suwayomi-Server-v#{version}.jar"
  license "MPL-2.0"

  livecheck do
    url "https://github.com/Suwayomi/Suwayomi-Server/releases"
    # Assets list is too long, .jar is hidden in folded "Show all * assets"
    regex(%r{href="[^"]+?/releases/download/[^/]+/Suwayomi-Server-v?(\d+(?:\.\d+)+-?[^">]*?)-mac[^"]+["' >]}i)
    strategy :page_match do |page|
      page.scan(regex).map { |match| match&.first }
    end
  end

  def pkg_name
    "suwayomi"
  end

  def bin_name
    "Suwayomi-Server"
  end

  def install
    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install pkg_name.to_s

    (buildpath/"suwayomi").write <<~EOS
      #!/bin/sh
      java -Dsuwayomi.tachidesk.config.server.debugLogsEnabled=false -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    (buildpath/"suwayomi-debug").write <<~EOS
      #!/bin/sh
      java -Dsuwayomi.tachidesk.config.server.debugLogsEnabled=true -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install Dir["suwayomi*"]

    prefix.install_metafiles
  end

  def post_install
    (var/"log/#{pkg_name}").mkpath
    chmod 0755, var/"log/#{pkg_name}"
  end

  def caveats
    <<~EOS
      Suwayomi-Server depends on Java 8+. Please install an available JDK manually.
      Note: Suwayomi-Server listens at 0.0.0.0:4567 by default.
      Default settings is generated automatically at first run into
        ~/Library/Application Support/Tachidesk/server.conf
      https://github.com/Suwayomi/Suwayomi-Server/wiki/Configuring-Tachidesk-Server
    EOS
  end

  service do
    environment_variables JAVA_HOME: "#{HOMEBREW_PREFIX}/opt/java"

    run %W[
      /usr/bin/java
      -Dsuwayomi.tachidesk.config.server.systemTrayEnabled=false
      -Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false
      -jar
      #{opt_prefix}/share/suwayomi/Suwayomi-Server.jar
    ]
    # keep_alive { succesful_exit: true }
    # log_path var/"log/suwayomi/suwayomi.log"
    # error_log_path var/"log/suwayomi/suwayomi.log"
  end
end
