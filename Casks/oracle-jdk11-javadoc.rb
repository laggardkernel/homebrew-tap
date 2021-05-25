cask 'oracle-jdk11-javadoc' do
  version "11.0.11,9:ab2da78f32ed489abb3ff52fd0a02b1c"
  # sha256

  url "https://download.oracle.com/otn-pub/java/jdk/#{version.before_comma}+#{version.after_comma.before_colon}/#{version.after_colon}/jdk-#{version.before_comma}_doc-all.zip",
    cookies: {
      'oraclelicense' => 'accept-securebackup-cookie',
    }
  name "Java Standard Edition Development Kit Documentation"
  homepage "https://www.oracle.com/java/technologies/javase-downloads.html#JDK#{version.major}"

  livecheck do
    url "https://www.oracle.com/java/technologies/javase-jdk11-doc-downloads.html"
    regex(%r{data-file=.+?/jdk/([^/]+)/([^/]+)/.+doc.+}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match|
        match&.first.sub("+", ",") + ":" + match&.second
      }
    end
  end

  postflight do
    `/usr/libexec/java_home -v #{version.before_comma} -X | grep -B0 -A1 JVMHomePath | sed -n -e 's/[[:space:]]*<string>\\(.*\\)<\\/string>/\\1/p'`.split("\n").each do |path|
      system_command '/bin/cp',
        args: ['-rp', "#{staged_path}/docs", "#{path}/"],
        sudo: true
    end
  end

  uninstall_postflight do
    `/usr/libexec/java_home -v #{version.before_comma} -X | grep -B0 -A1 JVMHomePath | sed -n -e 's/[[:space:]]*<string>\\(.*\\)<\\/string>/\\1/p'`.split("\n").each do |path|
      next unless File.exist?("#{path}/docs")

      system_command '/bin/rm',
        args: ['-rf', "#{path}/docs"],
        sudo: true
    end
  end

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/index.html'
  end
end
# https://github.com/Homebrew/homebrew-cask/commit/56e803e912358345527e04db5c61be2946430389
# https://github.com/Homebrew/homebrew-cask/pull/53702
