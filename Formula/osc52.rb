require "base64"

class Osc52 < Formula
  desc "Send string to the terminal clipboard using the OSC 52 escape sequence"
  homepage "https://chromium.googlesource.com/apps/libapps/+log/master/hterm/etc/osc52.sh"
  # rubocop: disable all
  version "250bcf7"
  url "https://chromium.googlesource.com/apps/libapps/+/#{version}/hterm/etc/osc52.sh?format=TEXT"
  # rubocop: enable all
  license :cannot_represent

  livecheck do
    url :homepage
    regex(%r{href="/apps/libapps/\+/([a-z0-9]{7,}+)"}i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  def install
    File.open("osc52.sh", "rt") do |f|
      content = f.read
      File.binwrite("osc52", Base64.decode64(content))
    end

    bin.install "osc52"
  end

  test do
    system bin/"osc52", "--help"
  end
end

# Ref
# - https://github.com/google/gitiles/issues/7, unable to download raw files
#   from googlesource
# curl -sSL https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/osc52.sh | base64 -D >| osc52
