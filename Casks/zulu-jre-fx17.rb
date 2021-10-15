cask "zulu-jre-fx17" do
  arch = Hardware::CPU.intel? ? "x64" : "aarch64"

  version "17.0.0,17.28.13-ca-fx"

  # TODO: dmg is provided for arch but not for x86?!
  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jre#{version.before_comma}-macosx_#{arch}.tar.gz",
      referer: "https://www.azul.com/downloads/?os=macos"
  # if Hardware::CPU.intel?
  #   # sha256 ""
  # else
  #   # sha256 ""
  # end

  name "Azul Zulu Java Standard Edition Development Kit"
  desc "OpenJRE distribution from Azul"
  homepage "https://www.azul.com/products/core/"

  livecheck do
    url "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?java_version=#{version.major}&bundle_type=jre&javafx=true&ext=dmg&os=macos"
    strategy :page_match do |page|
      match = page.match(/zulu(\d+(?:\.\d+)*-.*?)-jre(\d+(?:\.\d+)*)-macosx_(aarch64|x64)\.dmg/i)
      "#{match[2]},#{match[1]}"
    end
  end

  depends_on macos: ">= :sierra"

  artifact "zulu-#{version.major}.jre", target: "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jre"

  preflight do
    staged_subfolder = staged_path.glob(["zulu*-ca-fx-jre*"]).first
    if staged_subfolder
      FileUtils.mv(Dir["#{staged_subfolder}/*"], staged_path)
      FileUtils.rm_rf(staged_subfolder)
    end
  end

  uninstall delete: "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jre"
end