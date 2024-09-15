class VersionFetcher
  def initialize
    @url = "https://github.com/ruanyf/fortunes/commits/master"
  end

  def version
    require "open-uri"
    require "net/http"
    require "json"

    html = URI(@url).open.read
    # href in payload json escape " as href href=\"/ruanyf/...
    # switch to use "oid":"000fb01261e4d119e4e988ce82f49fb8b139fe3c",
    # or consider using https://api.github.com/repos/ruanyf/fortunes/commits
    # regex = /href=\\"\/ruanyf\/fortunes\/commit\/([a-z0-9]{7,}+)\\">/
    regex = /"oid":\s*"([a-z0-9]{7,}+)"/
    m = html.match(regex)
    if m
      m[1][0..6]
    else
      "latest"
    end
  end
end

class FortuneZh < Formula
  desc "Infamous electronic fortune-cookie generator, with additional zsh datfiles"
  homepage "https://www.ibiblio.org/pub/linux/games/amusements/fortune/!INDEX.html"
  # rubocop: disable all
  version "9708,000fb01"
  url "https://www.ibiblio.org/pub/linux/games/amusements/fortune/fortune-mod-#{version.to_s.split(",").first}.tar.gz"
  # rubocop: enable all
  # mirror ""  # link contains hash, don't wanna update it manually

  livecheck do
    datfile_version = VersionFetcher.new.version.to_s
    url "https://www.ibiblio.org/pub/linux/games/amusements/fortune/"
    regex(/href=.*?fortune-mod[._-]v?(\d+(?:\.\d+)*)\.t/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match&.first&.+ "," + datfile_version
      end
    end
  end

  resource "datfile" do
    # TODO: unable to access variable 'version' in resource block
    url "https://github.com/ruanyf/fortunes/archive/master.tar.gz" # rubocop: disable all
  end

  def install
    ENV.deparallelize

    inreplace "Makefile" do |s|
      # Don't install offensive quotes
      s.change_make_var! "OFFENSIVE", "0"

      # Use our selected compiler
      s.change_make_var! "CC", ENV.cc

      # Change these first two folders to the correct location in /usr/local...
      s.change_make_var! "FORTDIR", "/usr/local/bin"
      s.gsub! "/usr/local/man", "/usr/local/share/man"
      # Now change all /usr/local at once to the prefix
      s.gsub! "/usr/local", prefix

      # macOS only supports POSIX regexes
      s.change_make_var! "REGEXDEFS", "-DHAVE_REGEX_H -DPOSIX_REGEX"
    end

    system "make", "install"

    ### Additonal zh datafiles ###
    # Dropped the idea to create a formula for datafile installation. It doesn't
    # integrate well with formula fortune, users have to reinstall the datafile
    # formula after each fortune upgrade.

    # 1. resource not available in post_install
    # 2. Make a copy into buildpath, --keep-tmp doesn't take effect on resource
    resource("datfile").stage do
      rm Dir.glob("data/*.dat")
      cp_r "data", "#{buildpath}/fortunes-zh"
    end
    Dir.glob("fortunes-zh/*").each do |v|
      # strfile compile one file at one time
      system bin/"strfile", v.to_s
    end
    cp Dir.glob("fortunes-zh/*"), "#{share}/games/fortunes/" # overwring by default
  end

  def caveats
    <<~EOS
      Fortune with additional datfiles escpecially useful for Chinese users.

      - fortunes: quotes in English, 5437 items
      - chinese:  quotes in Chinese, 25919 items
      - tang300:  poems of Tang Dynasty in Chinese, 313 items
      - song100:  poems of Song Dynasty in Chinese, 95 items
      - diet:     diet proverbs in Chinese, 123 items

      Datfiles collection from https://github.com/ruanyf/fortunes
      Homebrew formula by https://github.com/laggardkernel
    EOS
  end

  test do
    system bin/"fortune", "-s", "tang300"
  end
end
