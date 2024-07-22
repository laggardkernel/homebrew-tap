class TmuxOptions < Formula
  desc "Terminal multiplexer with custom FPS"
  homepage "https://tmux.github.io/"
  version "3.4"
  revision 1
  url "https://github.com/tmux/tmux/releases/download/#{version}/tmux-#{version}.tar.gz"
  # sha256 ""
  license "ISC"

  livecheck do
    # Pre-release support
    url "https://github.com/tmux/tmux/releases/"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[-]?[a-z]*)["' >]}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
    # url :stable
    # regex(/v?(\d+(?:\.\d+)+[a-z]?)/i)
    # strategy :github_latest
  end

  head do
    url "https://github.com/tmux/tmux.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # Obsolete: devel block support is dropped
  # devel do
  #   url "https://github.com/tmux/tmux/releases/download/3.2-rc/tmux-3.2-rc3.tar.gz"
  #   sha256 ""
  # end

  option "with-fps-60", "FPS 60 (otherwise 20)"

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"

  uses_from_macos "bison" => :build # for yacc

  # Old versions of macOS libc disagree with utf8proc character widths.
  # https://github.com/tmux/tmux/issues/2223
  on_system :linux, macos: :sierra_or_newer do
    depends_on "utf8proc"
  end

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux"
    sha256 "b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f"
  end

  def install
    # Deprecate: ARGV
    # if ! (ARGV.value("with-fps").nil? || ARGV.value("with-fps").empty?)
    #   fps=ARGV.value("with-fps").to_i
    fps = if build.with? "fps-60"
      60
    else
      20
    end

    redraw_interval=(1_000_000/fps).round
    inreplace "tty.c" do |s|
      # #define TTY_BLOCK_INTERVAL (100000 /* 100 milliseconds */) # default 10
      s.gsub!(/^#define TTY_BLOCK_INTERVAL .*$/, "#define TTY_BLOCK_INTERVAL (#{redraw_interval} /* #{fps} fps */)")
    end

    system "sh", "autogen.sh" if build.head?

    args = %W[
      --enable-sixel
      --sysconfdir=#{etc}
    ]

    if OS.mac?
      # tmux finds the `tmux-256color` terminfo provided by our ncurses
      # and uses that as the default `TERM`, but this causes issues for
      # tools that link with the very old ncurses provided by macOS.
      # https://github.com/Homebrew/homebrew-core/issues/102748
      args << "--with-TERM=screen-256color" if MacOS.version < :sonoma
      args << "--enable-utf8proc" if MacOS.version >= :high_sierra
    else
      args << "--enable-utf8proc"
    end

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args, *std_configure_args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}

      If you encounter problem of terminfo not found reported by portable-ruby, e.g.
      reline/terminfo.rb:108:in `setupterm': The terminfo database could not be found. (Reline::Terminfo::TerminfoError)
      Add terminfo of tmux-256color into
        $HOMEBREW_PREFIX/Library/Homebrew/vendor/portable-ruby/current/share/terminfo
      which is the `TERMINFO_DIRS` used by some `brew` sub commands.
    EOS
  end

  test do
    system bin/"tmux", "-V"

    require "pty"

    socket = testpath/tap.user
    PTY.spawn bin/"tmux", "-S", socket, "-f", "/dev/null"
    sleep 10

    assert_predicate socket, :exist?
    assert_predicate socket, :socket?
    assert_equal "no server running on #{socket}", shell_output("#{bin}/tmux -S#{socket} list-sessions 2>&1", 1).chomp
  end
end

# Deprecate ARGV
# https://github.com/Homebrew/brew/issues/1803
# https://github.com/Homebrew/brew/issues/7093
# https://github.com/Homebrew/brew/issues/5730
# https://github.com/Homebrew/brew/pull/6857
# Even Homebrew.args is private?
