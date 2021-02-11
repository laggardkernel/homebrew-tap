class AdguardhomeBin < Formula
  desc "Network-wide ads & trackers blocking DNS server"
  homepage "https://github.com/AdguardTeam/AdGuardHome"
  version "0.105.0"
  url "https://github.com/AdguardTeam/AdGuardHome/releases/download/v#{version}/AdGuardHome_darwin_amd64.zip"
  sha256 "a47f2c3743549275da5e9b3589ad7ec668a1ef198276727d4f49fb45c41753e2"

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
