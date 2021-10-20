class Hmcl < Formula
  desc "Hello Minecraft! Launcher: multi-functional, cross-platform and popular"
  homepage "https://hmcl.huangyuhui.net/"
  # https://github.com/huanghongxun/HMCL
  version "3.4.208"
  # url "https://github.com/huanghongxun/HMCL/releases/download/v#{version}/HMCL-#{version}.jar"
  url "https://ci.huangyuhui.net/job/HMCL/#{version.to_s.split(".").last}/artifact/HMCL/build/libs/HMCL-#{version}.jar"
  license "GPL-3.0"

  livecheck do
    # https://hmcl.huangyuhui.net/changelog/stable.html
    # https://hmcl.huangyuhui.net/changelog/dev.html
    url "https://ci.huangyuhui.net/job/HMCL/"
    regex(/href=.*?HMCL-v?(\d+(?:\.\d+)*)\.jar/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
  end

  def install
    pkg_name="hmcl"
    bin_name="HMCL"

    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install "#{pkg_name}"

    (buildpath/"#{bin_name.downcase}").write <<~EOS
      #!/bin/sh
      if [ -n "$XDG_DATA_HOME" ]; then
        GAMEDIR="$XDG_DATA_HOME"
      else
        GAMEDIR="$HOME/.local/share"
      fi
      # No support to specify working directory with command line options.
      #  Just 'cd' into it. https://github.com/huanghongxun/HMCL/issues/317
      [ -d "$GAMEDIR" ] || mkdir -p "$GAMEDIR"
      cd "$HOME/.local/share"
      java -jar "#{opt_prefix}/share/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install "#{bin_name.downcase}"

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
