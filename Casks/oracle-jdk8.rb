# References
# url "https://mirrors.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-macosx-x64.dmg"
cask 'oracle-jdk8' do
  # version '1.8.0_192-b12,750e1c8617c5452694857ad95c3ee230'  # from oracle
  # java_update = version.sub(%r{.*_(\d+)-.*}, '\1')
  # url "https://download.oracle.com/otn-pub/java/jdk/#{version.minor}u#{version.before_comma.split('_').last}/#{version.after_comma}/jdk-#{version.minor}u#{java_update}-macosx-x64.dmg",
  #     cookies: {
  #                'oraclelicense' => 'accept-securebackup-cookie',
  #              }
  # homepage "https://www.oracle.com/technetwork/java/javase/downloads/jdk#{version.minor}-downloads.html"

  version "1.8.0_281"
  sha256 "cf09453ad1f6c84b4018d39a526c213a644415471af1e90b7e5d18633cfe3b08"
  java_update = version.sub(%r{.*_(\d+)}, '\1')

  url "http://download.macromedia.com/pub/coldfusion/java/java#{version.minor}/#{version.minor}u#{java_update}/jdk/jdk-#{version.minor}u#{java_update}-macosx-x64.dmg"
  name "Java Standard Edition Development Kit"
  homepage "https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers"

  # auto_updates true: JDK does not auto-update

  pkg "JDK #{version.minor} Update #{java_update}.pkg"

  postflight do
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string WebStart', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string Applets', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home", '/Library/Java/Home'],
                   sudo: true
    system_command '/bin/mkdir',
                   args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home/bundle/Libraries"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home/jre/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
                   sudo: true
  end

  uninstall pkgutil:   [
                         "com.oracle.jdk#{version.minor}u#{java_update}",
                         'com.oracle.jre',
                       ],
            launchctl: [
                         'com.oracle.java.Helper-Tool',
                         'com.oracle.java.Java-Updater',
                       ],
            quit:      [
                         'com.oracle.java.Java-Updater',
                         'net.java.openjdk.cmd', # Java Control Panel
                       ],
            delete:    [
                         '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin',
                         "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents",
                         '/Library/PreferencePanes/JavaControlPanel.prefPane',
                         '/Library/Java/Home',
                       ],
            rmdir:     "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk"

  zap trash: [
               '~/Library/Application Support/Java/',
               '~/Library/Application Support/Oracle/Java',
               '~/Library/Caches/com.oracle.java.Java-Updater',
               '~/Library/Caches/Oracle.MacJREInstaller',
               '~/Library/Caches/net.java.openjdk.cmd',
               '~/Library/Preferences/com.oracle.java.Java-Updater.plist',
               '~/Library/Preferences/com.oracle.java.JavaAppletPlugin.plist',
               '~/Library/Preferences/com.oracle.javadeployment.plist',
             ],
      rmdir: '~/Library/Application Support/Oracle/'

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/index.html'
    <<~EOS
      This Cask makes minor modifications to the JRE to prevent issues with
      packaged applications, as discussed here:
        https://bugs.eclipse.org/bugs/show_bug.cgi?id=411361
      If your Java application still asks for JRE installation, you might need
      to reboot or logout/login.
    EOS
  end
end
