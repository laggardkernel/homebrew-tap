class AtoolCustom < Formula
  desc "Archival front-end"
  homepage "https://savannah.nongnu.org/projects/atool/"
  # rubocop: disable all
  version "a967924"
  url "https://github.com/z3ntu/atool/archive/#{version}.tar.gz"
  # rubocop: enable all
  license "GPL-2.0-or-later"

  conflicts_with "atool", because: "they are variants of the same package"

  livecheck do
    url "https://github.com/z3ntu/atool/commits"
    regex(%r{/commit/([a-z0-9]{7,}+)"}i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    touch "example.txt"
    touch "example2.txt"
    system bin/"apack", "test.tar.gz", "example.txt", "example2.txt"

    output = shell_output("#{bin}/als test.tar.gz")
    assert_match "example.txt", output
    assert_match "example2.txt", output
  end
end
