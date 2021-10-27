cask "zulu-jdk-fx11" do
  arch = Hardware::CPU.intel? ? "x64" : "aarch64"

  version "11.0.13,11.52.13-ca-fx"

  # Note: prefer tar.gz over dmg for installation cause the later not only put
  #  files into /Library/Java/JavaVirtualMachines, but also a backup of .pkg
  #  under #{HOMEBREW_PREFIX}/Caskroom. If install with tar.gz, only stores
  #  a symlink under Caskroom.
  #  Besides. dmg of FX 17 is provided for arch but not for x64..
  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jdk#{version.before_comma}-macosx_#{arch}.tar.gz",
      referer: "https://www.azul.com/downloads/?os=macos"
  # if Hardware::CPU.intel?
  #   # sha256 ""
  # else
  #   # sha256 ""
  # end

  name "Azul Zulu Java Standard Edition Development Kit"
  desc "OpenJDK distribution with JavaFX from Azul"
  homepage "https://www.azul.com/products/core/"

  livecheck do
    url "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?java_version=#{version.major}&bundle_type=jdk&javafx=true&ext=dmg&os=macos"
    strategy :page_match do |page|
      match = page.match(/zulu(\d+(?:\.\d+)*-.*?)-jdk(\d+(?:\.\d+)*)-macosx_(aarch64|x64)\.dmg/i)
      "#{match[2]},#{match[1]}"
    end
  end

  depends_on macos: ">= :sierra"

  artifact "zulu-#{version.major}.jdk", target: "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk"

  preflight do
    staged_subfolder = staged_path.glob(["zulu*-ca-fx-jdk*"]).first
    if staged_subfolder
      FileUtils.mv(Dir["#{staged_subfolder}/*"], staged_path)
      FileUtils.rm_rf(staged_subfolder)
    end
  end

  uninstall delete: "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk"

  # pkg "Double-Click to Install Azul Zulu JDK #{version.major}.pkg"
  # uninstall pkgutil: "com.azulsystems.zulu.#{version.major}"
end
