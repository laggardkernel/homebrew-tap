cask 'oracle-jdk11' do
  version "11.0.10,8:020c4a6d33b74f6a9d2bc6fbf189da81"
  sha256 "99a62756676329bb02299f6e4e486cd264213a8ffb1d26cf6e00a3c9c3d0b5fb"
  name 'Java Standard Edition Development Kit'

  # Download from Oracle
  url "https://download.oracle.com/otn-pub/java/jdk/#{version.before_comma}+#{version.after_comma.before_colon}/#{version.after_colon}/jdk-#{version.before_comma}_osx-x64_bin.dmg",
      cookies: {
                 'oraclelicense' => 'accept-securebackup-cookie',
               }
  homepage "https://www.oracle.com/java/technologies/javase-downloads.html#JDK#{version.major}"
  pkg "JDK #{version.before_comma}.pkg"

  # # Download from Adobe
  # url "http://download.macromedia.com/pub/coldfusion/java/java#{version.major}/#{version.major}#{version.patch}/jdk-#{version}_osx-x64_bin.dmg"
  # homepage "https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers"
  # pkg "JDK #{version}.pkg"

  # auto_updates true: JDK does not auto-update

  depends_on macos: '>= :yosemite'

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
            rmdir:   "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk"

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/javase-license.html'
  end
end
