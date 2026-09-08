cask "font-apple-sf-mono" do
  version :latest
  sha256 :no_check

  url "file:///dev/null"
  name "Sans Francisco Mono"
  name "SF Mono"
  desc "Apple's SF Mono font"
  homepage "https://developer.apple.com/fonts/"

  conflicts_with cask: "font-sf-mono"

  # depends_on macos: ">= :sierra"

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

  preflight_steps do
    remove "null"

    if_path_exists "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts" do
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Bold.otf",
           "SF-Mono-Bold.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-BoldItalic.otf",
           "SF-Mono-BoldItalic.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Heavy.otf",
           "SF-Mono-Heavy.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-HeavyItalic.otf",
           "SF-Mono-HeavyItalic.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Light.otf",
           "SF-Mono-Light.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-LightItalic.otf",
           "SF-Mono-LightItalic.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Medium.otf",
           "SF-Mono-Medium.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-MediumItalic.otf",
           "SF-Mono-MediumItalic.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Regular.otf",
           "SF-Mono-Regular.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-RegularItalic.otf",
           "SF-Mono-RegularItalic.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Semibold.otf",
           "SF-Mono-Semibold.otf"
      copy "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-SemiboldItalic.otf",
           "SF-Mono-SemiboldItalic.otf"
    end
    if_path_exists "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts" do
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Bold.otf",
           "SF-Mono-Bold.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-BoldItalic.otf",
           "SF-Mono-BoldItalic.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Heavy.otf",
           "SF-Mono-Heavy.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-HeavyItalic.otf",
           "SF-Mono-HeavyItalic.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Light.otf",
           "SF-Mono-Light.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-LightItalic.otf",
           "SF-Mono-LightItalic.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Medium.otf",
           "SF-Mono-Medium.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-MediumItalic.otf",
           "SF-Mono-MediumItalic.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Regular.otf",
           "SF-Mono-Regular.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-RegularItalic.otf",
           "SF-Mono-RegularItalic.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-Semibold.otf",
           "SF-Mono-Semibold.otf"
      copy "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-SemiboldItalic.otf",
           "SF-Mono-SemiboldItalic.otf"
    end
  end
end
