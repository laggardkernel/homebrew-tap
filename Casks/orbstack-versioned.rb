cask "orbstack-versioned" do
  arch arm: "arm64", intel: "amd64"

  # https://docs.orbstack.dev/release-notes
  on_monterey :or_older do
    version "1.7.5,18165"
    sha256 arm:   "b9a740f932ff2609530cc12032016e5d7977074ae10e642bd1f7d49c65490b06",
           intel: "67ec06fc9ea26496cda033524049200b28da0ae8cae8744202368385755d14b0"
  end
  on_ventura :or_newer do
    version "1.11.3,19358"
    sha256 arm:   "ff3ba392672d31d2549b777b4638de89cf10aef592944014863160a2e05778dc",
           intel: "a0b39329e90353cf34a7d0edcdc47f9aec333ee140defbbbf3d68460d15b731f"
  end

  url "https://cdn-updates.orbstack.dev/#{arch}/OrbStack_v#{version.csv.first}_#{version.csv.second}_#{arch}.dmg"
  name "OrbStack"
  desc "Replacement for Docker Desktop"
  homepage "https://orbstack.dev/"

  livecheck do
    skip "Legacy version"
  end

  auto_updates true
  depends_on macos: "<= :ventura"

  app "OrbStack.app"
  binary "#{appdir}/OrbStack.app/Contents/MacOS/bin/orb"
  binary "#{appdir}/OrbStack.app/Contents/MacOS/bin/orbctl"
  bash_completion "#{appdir}/OrbStack.app/Contents/Resources/completions/bash/orbctl.bash"
  fish_completion "#{appdir}/OrbStack.app/Contents/Resources/completions/fish/orbctl.fish"
  zsh_completion "#{appdir}/OrbStack.app/Contents/Resources/completions/zsh/_orb"
  zsh_completion "#{appdir}/OrbStack.app/Contents/Resources/completions/zsh/_orbctl"

  postflight do
    system_command "#{appdir}/OrbStack.app/Contents/MacOS/bin/orbctl",
                   args: ["_internal", "brew-postflight"]
  end

  uninstall script: {
    executable: "#{appdir}/OrbStack.app/Contents/MacOS/bin/orbctl",
    args:       ["_internal", "brew-uninstall"],
  }

  zap trash: [
        "~/.orbstack",
        "~/Library/Caches/dev.kdrag0n.MacVirt",
        "~/Library/Group Containers/*.dev.orbstack",
        "~/Library/HTTPStorages/dev.kdrag0n.MacVirt",
        "~/Library/HTTPStorages/dev.kdrag0n.MacVirt.binarycookies",
        "~/Library/Preferences/dev.kdrag0n.MacVirt.plist",
        "~/Library/Saved Application State/dev.kdrag0n.MacVirt.savedState",
        "~/Library/WebKit/dev.kdrag0n.MacVirt",
      ],
      rmdir: "~/OrbStack"

  caveats <<~EOS
    Open the OrbStack app to finish setup.
  EOS
end
