cask "iina-versioned" do
  # https://github.com/iina/iina/issues/5277
  # https://iina.io/download/
  version "1.3.0,131" # force filename but not video title
  sha256 "b50c416828005e1eec0dc8066c961efcc389e6be1a5a595541ea62d48d31a391"

  # url "https://dl-portal.iina.io/IINA.v#{version.csv.first}.dmg"
  url "https://github.com/iina/iina/releases/download/v#{version.csv.first}/IINA.v#{version.csv.first}.dmg"
  name "IINA"
  desc "Free and open-source media player"
  homepage "https://iina.io/"

  # livecheck do
  #   url "https://www.iina.io/appcast.xml"
  #   strategy :sparkle # IINA sometimes rebuilds with the same short version.
  # end
  livecheck do
    skip "Legacy version"
  end

  auto_updates true
  # depends_on macos: ">= :high_sierra"  # >=1.3.2
  # depends_on macos: ">= :el_capitan" # < 1.3.2

  app "IINA.app"
  binary "#{appdir}/IINA.app/Contents/MacOS/iina-cli", target: "iina"

  uninstall quit: "com.colliderli.iina"

  zap trash: [
    "~/Library/Application Scripts/com.colliderli.iina.OpenInIINA",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.colliderli.iina.sfl*",
    "~/Library/Application Support/com.colliderli.iina",
    "~/Library/Application Support/CrashReporter/IINA*.plist",
    "~/Library/Caches/com.colliderli.iina",
    "~/Library/Containers/com.colliderli.iina.OpenInIINA",
    "~/Library/Cookies/com.colliderli.iina.binarycookies",
    "~/Library/HTTPStorages/com.colliderli.iina",
    "~/Library/Logs/com.colliderli.iina",
    "~/Library/Logs/DiagnosticReports/IINA*.crash",
    "~/Library/Preferences/com.colliderli.iina.plist",
    "~/Library/Safari/Extensions/Open in IINA*.safariextz",
    "~/Library/Saved Application State/com.colliderli.iina.savedState",
    "~/Library/WebKit/com.colliderli.iina",
  ]
end
