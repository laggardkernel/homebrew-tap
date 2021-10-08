class McaselectorAT115 < Formula
  desc "A tool to select chunks from Minecraft worlds for deletion or export."
  homepage "https://github.com/toolbox4minecraft/amidst"
  version "1.15.4"
  url "https://github.com/Querz/mcaselector/releases/download/#{version}/mcaselector-#{version}.jar"
  license "GPL-3.0"

  # keg_only :versioned_formula

  deprecate! date: "2021-05-11", because: :unsupported

  bottle :unneeded

  def install
    pkg_name="mcaselector@1.15"
    bin_name="mcaselector"

    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install "#{pkg_name}"

    (buildpath/"#{bin_name.downcase}").write <<~EOS
      #!/bin/sh
      java -jar "#{opt_prefix}/share/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install "#{bin_name.downcase}"

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      Since mcaselector 1.16, minimal Java requirement is Java 16 with JavaFX.

      https://github.com/Querz/mcaselector
    EOS
  end
end
