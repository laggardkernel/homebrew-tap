cask 'oracle-jdk8' do
  version "1.8.0_291-b10,d7fc238d0cbf4b0dac67be84580cfb4b"
  sha256 "632c4fbbec39846651c65f5c93d2035567046fd60bc0e58ef431218dffa8cc15"

  java_update = version.sub(%r{.*_(\d+)-.*}, '\1')
  url "https://download.oracle.com/otn-pub/java/jdk/#{version.minor}u#{version.before_comma.split('_').last}/#{version.after_comma}/jdk-#{version.minor}u#{java_update}-macosx-x64.dmg",
    cookies: {
      'oraclelicense' => 'accept-securebackup-cookie',
    }
  name "Java Standard Edition Development Kit"
  homepage "https://www.oracle.com/java/technologies/javase-downloads.html#JDK#{version.minor}"

  livecheck do
    url "https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html"
    regex(%r{data-file=.+?/jdk/([^/]+)/([^/]+).+?macosx?.+?\.dmg}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match|
        match&.first.sub(/^8u/, "1.8.0_") + "," + match&.second
      }
    end
  end

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

    if MacOS.version <= :mavericks
      system_command '/bin/rm',
        args: ['-rf', '--', '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK'],
        sudo: true
      system_command '/bin/ln',
        args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents", '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK'],
        sudo: true
    end
  end

  uninstall_preflight do
    if File.exist?("#{HOMEBREW_PREFIX}/Caskroom/oracle-jdk8-javadoc")
      system_command 'brew', args: ['cask', 'uninstall', 'oracle-jdk8-javadoc']
    end

    # if File.exist?("#{HOMEBREW_PREFIX}/Caskroom/jce-unlimited-strength-policy")
    #   system_command 'brew', args: ['cask', 'uninstall', 'jce-unlimited-strength-policy']
    # end
  end

  uninstall pkgutil:   [
    "com.oracle.jdk#{version.minor}u#{java_update}",
    'com.oracle.jre',
  ],
  launchctl: [
    'com.oracle.java.Helper-Tool',
    'com.oracle.java.Java-Updater',
  ],
  quit: [
    'com.oracle.java.Java-Updater',
    'net.java.openjdk.cmd', # Java Control Panel
  ],
  delete: [
    '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin',
    "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents",
    '/Library/PreferencePanes/JavaControlPanel.prefPane',
    '/Library/Java/Home',
    if MacOS.version <= :mavericks
      [
        '/usr/lib/java/libjdns_sd.jnilib',
        '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK',
      ]
    end,
  ].keep_if { |v| !v.nil? }

  zap delete: [
    '~/Library/Caches/com.oracle.java.Java-Updater',
    '~/Library/Caches/Oracle.MacJREInstaller',
    '~/Library/Caches/net.java.openjdk.cmd',
  ],
  trash: [
    '~/Library/Application Support/Java/',
    '~/Library/Application Support/Oracle/Java',
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
# ~~https://github.com/Homebrew/homebrew-cask/commit/4a0f29a4e51355106dc0264360d9779cf59991e3~~
# https://github.com/Homebrew/homebrew-cask/commit/b1a4ec15579ab373e7d9adfccdae5416b645553f
# https://github.com/Homebrew/homebrew-cask/blob/ecc181b05e72042f6a799bbc8754e06dceda6b62/Casks/java.rb
# https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers
