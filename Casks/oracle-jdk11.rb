cask "oracle-jdk11" do
  version "11.0.11,9:ab2da78f32ed489abb3ff52fd0a02b1c"
  sha256 "d4519ad54bd92c6477fc04b1c15927629b707593ef9f0ab205017e922db24a38"

  url "https://download.oracle.com/otn-pub/java/jdk/#{version.before_comma}+#{version.after_comma.before_colon}/#{version.after_colon}/jdk-#{version.before_comma}_osx-x64_bin.dmg",
      cookies: {
        "oraclelicense" => "accept-securebackup-cookie",
      }
  name "Java Standard Edition Development Kit"
  homepage "https://www.oracle.com/java/technologies/javase-downloads.html#JDK#{version.major}"

  livecheck do
    url "https://www.oracle.com/java/technologies/javase-jdk11-downloads.html"
    regex(%r{data-file=.+?/(\d+(?:\.\d+)*)(\+|%2B)(\d+(?:\.\d+)*)/(.+)/jdk-(\d+(?:.\d+)*).*?osx.*?\.dmg}i)
    strategy :page_match do |page, regex|
      match = page.match(regex)
      "#{match[1]},#{match[3]}:#{match[4]}"
    end
  end

  # auto_updates true: JDK does not auto-update
  depends_on macos: ">= :yosemite"

  pkg "JDK #{version.before_comma}.pkg"

  # Uninstall doc in postflight to avoid doing 'sudo rm' in sub 'brew uninstall'
  # Password input prompt can't be popped up in a recursive brew call?
  uninstall_postflight do
    if File.exist?("#{HOMEBREW_PREFIX}/Caskroom/oracle-jdk11-javadoc")
      system_command "#{HOMEBREW_PREFIX}/bin/brew", args: ["uninstall", "--cask", "oracle-jdk11-javadoc"]
    end
  end

  uninstall pkgutil: "com.oracle.jdk-#{version.before_comma}",
            delete:  "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk"

  caveats do
    license "https://www.oracle.com/technetwork/java/javase/terms/license/javase-license.html"
  end
end
# Related commits
# https://github.com/Homebrew/homebrew-cask/commit/2bb687a5503f802022559b15987dc919d59cb28d
# https://github.com/Homebrew/homebrew-cask/pull/57655
# https://github.com/Homebrew/homebrew-cask/commit/4ba1e78fe8319e0f590048bf6070ad269c646bf2
# Remove workarounds in Java cask
# https://github.com/Homebrew/homebrew-cask/pull/58510
# https://github.com/Homebrew/homebrew-cask-versions/pull/6949
# Don't remove /Library/Java/JavaVirtualMachines
# https://github.com/Homebrew/homebrew-cask/commit/7392cc0a5042aa53913285a99212f9c6955702db
# Cleanup deployment stack, JRE, etc in JDK 11
# https://github.com/Homebrew/homebrew-cask/pull/52605
# Alternative download resource
# https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers
