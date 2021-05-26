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
  end

  # Uninstall doc in postflight to avoid doing 'sudo rm' in sub 'brew uninstall'
  # Password input prompt can't be popped up in a recursive brew call?
  uninstall_postflight do
    if File.exist?("#{HOMEBREW_PREFIX}/Caskroom/oracle-jdk8-javadoc")
      system_command "#{HOMEBREW_PREFIX}/bin/brew", args: ['uninstall', '--cask', 'oracle-jdk8-javadoc']
    end
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
    "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk",
    '/Library/PreferencePanes/JavaControlPanel.prefPane',
  ]

  zap trash: [
    # From 1.9
    # https://github.com/Homebrew/homebrew-cask/commit/b1a4ec15579ab373e7d9adfccdae5416b645553f
    '/Library/Application Support/Oracle/Java',
    '/Library/Preferences/com.oracle.java.Deployment.plist',
    '/Library/Preferences/com.oracle.java.Helper-Tool.plist',
    # Original from 1.8
    '~/Library/Application Support/Java/',
    '~/Library/Application Support/Oracle/Java',
    '~/Library/Caches/com.oracle.java.Java-Updater',
    '~/Library/Caches/Oracle.MacJREInstaller',
    '~/Library/Caches/net.java.openjdk.cmd',
    '~/Library/Preferences/com.oracle.java.Java-Updater.plist',
    '~/Library/Preferences/com.oracle.java.JavaAppletPlugin.plist',
    '~/Library/Preferences/com.oracle.javadeployment.plist',
  ],
  rmdir: [
    '/Library/Application Support/Oracle/',
    '~/Library/Application Support/Oracle/',
  ]

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
# Related commits
# ~~https://github.com/Homebrew/homebrew-cask/commit/4a0f29a4e51355106dc0264360d9779cf59991e3~~
# https://github.com/Homebrew/homebrew-cask/blob/ecc181b05e72042f6a799bbc8754e06dceda6b62/Casks/java.rb
# https://github.com/Homebrew/homebrew-cask/commit/b1a4ec15579ab373e7d9adfccdae5416b645553f
# Remove workarounds in Java cask
# https://github.com/Homebrew/homebrew-cask/pull/58510
# https://github.com/Homebrew/homebrew-cask-versions/pull/6949
# Cleanup deployment stack, JRE, etc in JDK 11
# https://github.com/Homebrew/homebrew-cask/pull/52605
# Alternative download resource
# https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers
