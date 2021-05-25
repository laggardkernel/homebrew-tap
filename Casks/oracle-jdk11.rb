cask 'oracle-jdk11' do
  version "11.0.11,9:ab2da78f32ed489abb3ff52fd0a02b1c"
  sha256 "d4519ad54bd92c6477fc04b1c15927629b707593ef9f0ab205017e922db24a38"

  url "https://download.oracle.com/otn-pub/java/jdk/#{version.before_comma}+#{version.after_comma.before_colon}/#{version.after_colon}/jdk-#{version.before_comma}_osx-x64_bin.dmg",
    cookies: {
      'oraclelicense' => 'accept-securebackup-cookie',
    }
  name 'Java Standard Edition Development Kit'
  homepage "https://www.oracle.com/java/technologies/javase-downloads.html#JDK#{version.major}"

  livecheck do
    url "https://www.oracle.com/java/technologies/javase-jdk11-downloads.html"
    regex(%r{data-file=.+?/jdk/([^/]+)/([^/]+).+?osx?.+?\.dmg}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match|
        match&.first.sub("%2B", ",") + ":" + match&.second
      }
    end
  end

  # auto_updates true: JDK does not auto-update
  depends_on macos: '>= :yosemite'

  pkg "JDK #{version.before_comma}.pkg"

  postflight do
    system_command '/bin/ln',
      args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/Home", '/Library/Java/Home'],
      sudo: true
    system_command '/bin/ln',
      args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/MacOS", '/Library/Java/MacOS'],
      sudo: true
    system_command '/bin/mkdir',
      args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/Home/bundle/Libraries"],
      sudo: true
    system_command '/bin/ln',
      args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/Home/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
      sudo: true
  end

  uninstall pkgutil: "com.oracle.jdk-#{version.before_comma}",
    delete:  [
      "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents",
      '/Library/Java/Home',
      '/Library/Java/MacOS',
    ],
    rmdir: "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk"

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/javase-license.html'
  end
end
# https://github.com/Homebrew/homebrew-cask/commit/2bb687a5503f802022559b15987dc919d59cb28d
# https://github.com/Homebrew/homebrew-cask/pull/57655
# https://github.com/Homebrew/homebrew-cask/commit/4ba1e78fe8319e0f590048bf6070ad269c646bf2
# https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers
