class Hmcl < Formula
  desc "Hello Minecraft! Launcher: multi-functional, cross-platform and popular"
  homepage "https://hmcl.huangyuhui.net/"
  # https://github.com/huanghongxun/HMCL
  version "3.5.0.214"
  # WARN: network quality of the ci site is unreliable, fetch releases from
  # github-actions instead.
  url "https://github.com/huanghongxun/HMCL/releases/download/v#{version}/HMCL-#{version}.jar"
  # url "https://ci.huangyuhui.net/job/HMCL/#{version.to_s.split(".").last}/artifact/HMCL/build/libs/HMCL-#{version}.jar"
  license "GPL-3.0"

  livecheck do
    url "https://github.com/huanghongxun/HMCL/releases"
    # url "https://ci.huangyuhui.net/job/HMCL/"
    regex(/href=.*?HMCL-v?(\d+(?:\.\d+)*)\.jar/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
  end

  def pkg_name
    "hmcl"
  end

  def bin_name
    "HMCL"
  end

  def install
    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install pkg_name.to_s

    (buildpath/bin_name.downcase.to_s).write <<~EOS
      #!/bin/sh
      # No support to specify working directory with command line options.
      #  Just 'cd' into it. https://github.com/huanghongxun/HMCL/issues/317
      cd "$HOME" && \\
      java -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install bin_name.downcase.to_s

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      https://github.com/huanghongxun/HMCL

      Hello Minecraft! Launcher (HMLC) depends on Java with JavaFX support.
      Make sure you have Java installed with JavaFX 8 at least.
    EOS
  end
end
