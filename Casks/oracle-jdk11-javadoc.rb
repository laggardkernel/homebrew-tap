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
    regex(%r{data-file=.+?/(\d+(?:\.\d+)*)(\+|%2B)(\d+(?:\.\d+)*)/(.+)/jdk-(\d+(?:.\d+)*).*?doc-all\.zip}i)
    strategy :page_match do |page, regex|
      match = page.match(regex)
      "#{match[1]},#{match[3]}:#{match[4]}"
    end
  end

  artifact 'docs', target: "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/Home/docs"

  uninstall delete: "/Library/Java/JavaVirtualMachines/jdk-#{version.before_comma}.jdk/Contents/Home/docs"

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/index.html'
  end
end
# Related commits
# https://github.com/Homebrew/homebrew-cask/commit/56e803e912358345527e04db5c61be2946430389
# https://github.com/Homebrew/homebrew-cask/pull/53702
# Remove workarounds in Java cask
# https://github.com/Homebrew/homebrew-cask/pull/58510
# https://github.com/Homebrew/homebrew-cask-versions/pull/6949
