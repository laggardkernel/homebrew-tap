class McaselectorAT115 < Formula
  desc "Tool to select chunks from Minecraft worlds for deletion or export"
  homepage "https://github.com/toolbox4minecraft/amidst"
  # rubocop: disable all
  version "1.15.4"
  url "https://github.com/Querz/mcaselector/releases/download/#{version}/mcaselector-#{version}.jar"
  # rubocop: enable all
  license "GPL-3.0"
  revision 1

  # keg_only :versioned_formula

  deprecate! date: "2021-05-11", because: :unsupported

  def pkg_name
    "mcaselector@1.15"
  end

  def bin_name
    "mcaselector"
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
      Since mcaselector 1.16, minimal Java requirement is Java 16 with JavaFX.

      https://github.com/Querz/mcaselector
    EOS
  end
end
