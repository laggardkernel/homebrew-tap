class TmuxOptions < Formula
  desc "Terminal multiplexer with custom FPS"
  homepage "https://tmux.github.io/"
  # rubocop: disable all
  version "3.6a"
  url "https://github.com/tmux/tmux/releases/download/#{version}/tmux-#{version}.tar.gz"
  # rubocop: enable all
  license "ISC"

  livecheck do
    url "https://github.com/tmux/tmux/releases/"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+-?[a-z]*)["' >]}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first }
    end
  end

  head do
    url "https://github.com/tmux/tmux.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-fps-60", "FPS 60 (otherwise 20)"

  conflicts_with "tmux", because: "they are variants of the same package"

  depends_on "pkg-config" => :build
  depends_on "jemalloc"
  depends_on "libevent"
  depends_on "ncurses"

  uses_from_macos "bison" => :build # for yacc

  # Old versions of macOS libc disagree with utf8proc character widths.
  # https://github.com/tmux/tmux/issues/2223
  if (OS.mac? && MacOS.version >= '10.12') || OS.linux?
    depends_on "utf8proc"
  end

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/8da7f797245970659b259b85e5409f197b8afddd/completions/tmux"
    sha256 "4e2179053376f4194b342249d75c243c1573c82c185bfbea008be1739048e709"
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
      --enable-jemalloc
      --enable-sixel
      --sysconfdir=#{etc}
    ]

    if OS.mac?
      # tmux finds the `tmux-256color` terminfo provided by our ncurses
      # and uses that as the default `TERM`, but this causes issues for
      # tools that link with the very old ncurses provided by macOS.
      # https://github.com/Homebrew/homebrew-core/issues/102748
      args << "--with-TERM=screen-256color" if MacOS.version < '14'
      args << "--enable-utf8proc" if MacOS.version >= '10.13'
    else
      args << "--enable-utf8proc"
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}

      If you encounter problem of 'terminfo not found' reported by portable-ruby, e.g.
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
    PTY.spawn bin/"tmux", "-S", socket, "-f", File::NULL
    sleep 10

    assert_predicate socket, :exist?
    assert_predicate socket, :socket?
    assert_equal "no server running on #{socket}", shell_output("#{bin}/tmux -S#{socket} list-sessions 2>&1", 1).chomp
  end
end
