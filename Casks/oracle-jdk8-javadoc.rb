cask 'oracle-jdk8-javadoc' do
  version "1.8.0_291-b10,d7fc238d0cbf4b0dac67be84580cfb4b"
  # sha256

  java_update = version.sub(%r{.*_(\d+)-.*}, '\1')
  url "http://download.oracle.com/otn-pub/java/jdk/#{version.minor}u#{version.before_comma.split('_').last}/#{version.after_comma}/jdk-#{version.minor}u#{java_update}-docs-all.zip",
    cookies: {
      'oraclelicense' => 'accept-securebackup-cookie',
    }
  name "Java Standard Edition Development Kit Documentation"
  homepage "https://www.oracle.com/java/technologies/javase-jdk8-doc-downloads.html"

  livecheck do
    url "https://www.oracle.com/java/technologies/javase-jdk8-doc-downloads.html"
    regex(%r{data-file=.+?/jdk/([^/]+)/([^/]+)/.+?docs-all.+?}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match|
        match&.first.sub(/^8u/, "1.8.0_") + "," + match&.second
      }
    end
  end

  postflight do
    `/usr/libexec/java_home -v #{version.before_comma.split('-').first} -X | grep -B0 -A1 JVMHomePath | sed -n -e 's/[[:space:]]*<string>\\(.*\\)<\\/string>/\\1/p'`.split("\n").each do |path|
      system_command '/bin/cp',
        args: ['-rp', "#{staged_path}/docs", "#{path}/"],
        sudo: true
    end
  end

  uninstall_postflight do
    `/usr/libexec/java_home -v #{version.before_comma.split('-').first} -X | grep -B0 -A1 JVMHomePath | sed -n -e 's/[[:space:]]*<string>\\(.*\\)<\\/string>/\\1/p'`.split("\n").each do |path|
      next unless File.exist?("#{path}/docs")

      system_command '/bin/rm',
        args: ['-rf', "#{path}/docs"],
        sudo: true
    end
  end

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/javase-license.html'
  end
end
# https://github.com/Homebrew/homebrew-cask/commit/1446709cebe573d5225366d2f88105e9900f9306
