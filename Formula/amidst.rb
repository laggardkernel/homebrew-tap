class Amidst < Formula
  desc "Advanced Minecraft Interface and Data/Structure Tracking"
  homepage "https://github.com/toolbox4minecraft/amidst"
  version "4.7"
  url "https://github.com/toolbox4minecraft/amidst/releases/download/v#{version}/amidst-v#{version.to_s.sub!('.', '-')}.jar"
  license "GPL-3.0"

  bottle :unneeded

  def install
    mkdir_p "./#{name}"
    mv Dir["#{name}-*.jar"][0], "./#{name}/#{name}.jar"
    share.install "#{name}"

    (buildpath/"#{name}").write <<~EOS
      #!/bin/sh
      java -jar "#{opt_prefix}/share/#{name}/#{name}.jar" "$@"
    EOS
    bin.install "#{name}"

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
