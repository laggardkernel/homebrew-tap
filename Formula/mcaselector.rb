class Mcaselector < Formula
  desc "A tool to select chunks from Minecraft worlds for deletion or export."
  homepage "https://github.com/toolbox4minecraft/amidst"
  version "1.16.3"
  url "https://github.com/Querz/mcaselector/releases/download/#{version}/mcaselector-#{version}.jar"
  license "GPL-3.0"

  bottle :unneeded

  def install
    mkdir_p "./#{name}"
    mv Dir["#{name}-*.jar"][0], "./#{name}/#{name}.jar"
    share.install "#{name}"

    (buildpath/"#{name}").write <<~EOS
      #!/bin/sh
      # Pre-compiled with newer (JDK 16)
      # https://stackoverflow.com/a/7334780/5101148
      version=`java -version 2>&1 | head -1 | cut -d '"' -f 2`
      version="${version%%.*}"
      if [ "$version" -lt 16 ]; then
        export JAVA_HOME="#{HOMEBREW_PREFIX}/opt/java"
        /usr/bin/java -jar "#{opt_prefix}/share/#{name}/#{name}.jar" "$@"
      else
        java -jar "#{opt_prefix}/share/#{name}/#{name}.jar" "$@"
      fi
    EOS
    bin.install "#{name}"

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      mcaselector depends on Java 16 with JavaFX support. Make sure you have them installed.
      https://github.com/Querz/mcaselector
    EOS
  end
end
