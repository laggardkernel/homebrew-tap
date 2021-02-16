class AdguardhomeBin < Formula
  desc "Network-wide ads & trackers blocking DNS server"
  homepage "https://github.com/AdguardTeam/AdGuardHome"
  version "0.105.1"
  url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_darwin_amd64.zip"
  sha256 "81d900fc962d7e567c7a24925dc52ca71e57b6fda4adb5ae64671aaf3787dd8b"

  conflicts_with "adguardhome", :because => "same package"

  def install
    # TODO: lowercase?
    bin.install "AdGuardHome"
    prefix.install_metafiles
    mkdir_p etc/"adguardhome"
  end

  test do
    system "#{bin}/AdGuardHome", "--version"
  end

  def caveats; <<~EOS
    Check https://github.com/AdguardTeam/AdGuardHome/wiki/Getting-Started for detail.

    Recommend saving config in #{etc}/adguardhome dir.

      sudo AdGuardHome -w #{etc}/adguardhome

    Launchd profile is not provided in Homebrew formula,
    cause AdGuardHome executable controls the launchd service by itself.

      sudo AdGuardHome -w #{etc}/adguardhome -s start
      sudo AdGuardHome -w #{etc}/adguardhome -s stop
  EOS
  end

end
