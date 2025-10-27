class Hmcl < Formula
  desc "Hello Minecraft! Launcher: multi-functional, cross-platform and popular"
  homepage "https://hmcl.huangyuhui.net/"
  # https://github.com/huanghongxun/HMCL
  # rubocop: disable all
  version "3.6.20"
  url "https://github.com/HMCL-dev/HMCL/releases/download/v#{version}/HMCL-#{version}.jar"
  # WARN: network quality of the ci site is unreliable, fetch releases from
  # github-actions instead.
  # url "https://ci.huangyuhui.net/job/HMCL/#{version.to_s.split(".").last}/artifact/HMCL/build/libs/HMCL-#{version}.jar"
  # rubocop: enable all
  license "GPL-3.0"

  livecheck do
    url "https://github.com/HMCL-dev/HMCL/releases"
    strategy :github_releases
    # assets content is loaded by javascript, match tag link
    # regex(%r{href=.*?HMCL/releases/tag/v?(\d+(?:\.\d+)*)[^"]*}i)
    # strategy :page_match do |page, regex|
    #   page.scan(regex).map { |match| match&.first }
    # end
    # url "https://ci.huangyuhui.net/job/HMCL/"
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
      #  Just 'cd' into it. https://github.com/HMCL-dev/HMCL/issues/317
      cd "$HOME" && \\
      java -jar "#{share}/#{pkg_name}/#{bin_name}.jar" "$@"
    EOS
    bin.install bin_name.downcase.to_s

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      https://github.com/HMCL-dev/HMCL

      Hello Minecraft! Launcher (HMLC) depends on Java with JavaFX support.
      Make sure you have Java installed with JavaFX 8 at least.
    EOS
  end
end
