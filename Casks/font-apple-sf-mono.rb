cask "font-apple-sf-mono" do
  version :latest
  sha256 :no_check

  url "file:///dev/null"
  name "Sans Francisco Mono"
  name "SF Mono"
  homepage "https://developer.apple.com/fonts/"

  conflicts_with cask: "font-sf-mono"
  depends_on macos: ">= :sierra"

  font "SF-Mono-Bold.otf"
  font "SF-Mono-BoldItalic.otf"
  font "SF-Mono-Heavy.otf"
  font "SF-Mono-HeavyItalic.otf"
  font "SF-Mono-Light.otf"
  font "SF-Mono-LightItalic.otf"
  font "SF-Mono-Medium.otf"
  font "SF-Mono-MediumItalic.otf"
  font "SF-Mono-Regular.otf"
  font "SF-Mono-RegularItalic.otf"
  font "SF-Mono-Semibold.otf"
  font "SF-Mono-SemiboldItalic.otf"

  preflight do
    FileUtils.rm("#{staged_path}/null") # remove dummy download file

    font_source_dir = if MacOS.version >= "10.15"
      "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts"
    else
      "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts"
    end
    Dir.chdir(font_source_dir.to_s) do
      %w[
        SF-Mono-Bold.otf
        SF-Mono-BoldItalic.otf
        SF-Mono-Heavy.otf
        SF-Mono-HeavyItalic.otf
        SF-Mono-Light.otf
        SF-Mono-LightItalic.otf
        SF-Mono-Medium.otf
        SF-Mono-MediumItalic.otf
        SF-Mono-Regular.otf
        SF-Mono-RegularItalic.otf
        SF-Mono-Semibold.otf
        SF-Mono-SemiboldItalic.otf
      ].each do |f|
        FileUtils.cp(f.to_s, "#{staged_path}/#{f}")
      end
    end
  end
end
