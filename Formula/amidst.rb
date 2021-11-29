class Amidst < Formula
  desc "Advanced Minecraft Interface and Data/Structure Tracking"
  homepage "https://github.com/toolbox4minecraft/amidst"
  version "4.7"
  url "https://github.com/toolbox4minecraft/amidst/releases/download/v#{version}/amidst-v#{version.to_s.sub!('.', '-')}.jar"
  license "GPL-3.0"
  revision 1

  def pkg_name
    "amidst"
  end

  def bin_name
    "amidst"
  end

  def install
    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install pkg_name.to_s

    (buildpath/bin_name.downcase.to_s).write <<~EOS
      #!/bin/sh
      java -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install bin_name.downcase.to_s

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      Amidst depends on Java with JavaFX support. Make sure you have them installed.
      https://github.com/toolbox4minecraft/amidst/wiki
    EOS
  end

  test do
    system "#{bin}/amidst", "-version"
  end
end
# Amidst.app doesn't work. Use formula instead.
#  https://github.com/toolbox4minecraft/amidst/issues/1049
