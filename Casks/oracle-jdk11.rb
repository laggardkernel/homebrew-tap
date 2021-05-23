cask 'oracle-jdk11' do
  version "11.0.11,9:ab2da78f32ed489abb3ff52fd0a02b1c"
  sha256 "d4519ad54bd92c6477fc04b1c15927629b707593ef9f0ab205017e922db24a38"
  name 'Java Standard Edition Development Kit'

  # Download from Oracle
  url "https://download.oracle.com/otn-pub/java/jdk/#{version.before_comma}+#{version.after_comma.before_colon}/#{version.after_colon}/jdk-#{version.before_comma}_osx-x64_bin.dmg",
    cookies: {
      'oraclelicense' => 'accept-securebackup-cookie',
    }
  homepage "https://www.oracle.com/java/technologies/javase-downloads.html#JDK#{version.major}"

  # # Download from Adobe
  # url "http://download.macromedia.com/pub/coldfusion/java/java#{version.major}/#{version.major}#{version.patch}/jdk-#{version}_osx-x64_bin.dmg"
  # homepage "https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers"
  # pkg "JDK #{version}.pkg"

  # auto_updates true: JDK does not auto-update

  livecheck do
    url "https://www.oracle.com/java/technologies/javase-jdk11-downloads.html"
    regex(%r{data-file=.+?/jdk/([^/]+)/([^/]+).+?osx?.+?\.dmg}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match|
        match&.first.sub(/%2B/, ",") + ":" + match&.second
      }
    end
  end

  depends_on macos: '>= :yosemite'

  pkg "JDK #{version.before_comma}.pkg"

  postflight do
    system_command '/bin/ln',
      args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home", '/Library/Java/Home'],
      sudo: true
    system_command '/bin/ln',
      args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/MacOS", '/Library/Java/MacOS'],
      sudo: true
    system_command '/bin/mkdir',
      args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home/bundle/Libraries"],
      sudo: true
    system_command '/bin/ln',
      args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
      sudo: true
  end

  uninstall pkgutil: "com.oracle.jdk-#{version}",
    delete:  [
      "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents",
      '/Library/Java/Home',
      '/Library/Java/MacOS',
    ],
    rmdir: "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk"

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/javase-license.html'
  end
end
