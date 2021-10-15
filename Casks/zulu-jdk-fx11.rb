cask "zulu-jdk-fx11" do
  arch = Hardware::CPU.intel? ? "x64" : "aarch64"

  version "11.0.12,11.50.19-ca-fx"

  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jdk#{version.before_comma}-macosx_#{arch}.dmg",
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

  pkg "Double-Click to Install Azul Zulu JDK #{version.major}.pkg"

  uninstall pkgutil: "com.azulsystems.zulu.#{version.major}"
end
