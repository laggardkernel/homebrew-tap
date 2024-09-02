cask "sourcetrail-versioned" do
  on_mojave :or_older do # if MacOS.version <= :mojave
    version "2021.1.30"
    sha256 "4af4d5e954dc82850c4065f5a44a3e87fa4373f2d979e631cb005c4f90721e02"
  end
  on_catalina :or_newer do
    version "2021.4.19"
    sha256 "b2155e5b1f6f97b466d404821a61b57d4db0040356cd7487827ea9a003d65291"
  end

  url "https://github.com/CoatiSoftware/Sourcetrail/releases/download/#{version}/Sourcetrail_#{version.dots_to_underscores}_macOS_64bit.dmg",
      verified: "github.com/CoatiSoftware/Sourcetrail/"
  name "Sourcetrail"
  desc "Code source explorer"
  homepage "https://www.sourcetrail.com/"

  livecheck do
    url "https://github.com/CoatiSoftware/Sourcetrail/releases"
    # strategy :github_latest
    strategy :page_match do |page|
      if MacOS.version <= :mojave # rubocop: disable all
        "2021.1.30"
      else
        regex(%r{href=.*?tree/v?(\d+(?:\.\d+)*)}i)
        page.scan(regex).map { |match| match&.first }
      end
    end
  end

  app "Sourcetrail.app"

  zap trash: [
    "~/Library/Application Support/Sourcetrail",
    "~/Library/Saved Application State/com.sourcetrail.savedState",
  ]
end
