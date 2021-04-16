class TmuxOptions < Formula
  desc 'Terminal multiplexer with custom FPS'
  homepage 'https://tmux.github.io/'
  url 'https://github.com/tmux/tmux/releases/download/3.2/tmux-3.2.tar.gz'
  sha256 '664d345338c11cbe429d7ff939b92a5191e231a7c1ef42f381cebacb1e08a399'
  license 'ISC'
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  bottle :unneeded

  head do
    url 'https://github.com/tmux/tmux.git'

    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'libtool' => :build
  end

  # Obsolete: devel block support is dropped
  # devel do
  #   url "https://github.com/tmux/tmux/releases/download/3.2-rc/tmux-3.2-rc3.tar.gz"
  #   sha256 ""
  # end

  # option "with-fps=", "FPS (default 20)"
  option 'with-fps-60', 'FPS 60 (default 20)'

  depends_on 'pkg-config' => :build
  depends_on 'libevent'
  depends_on 'ncurses'

  # Old versions of macOS libc disagree with utf8proc character widths.
  # https://github.com/tmux/tmux/issues/2223
  depends_on 'utf8proc' if OS.mac? && MacOS.version >= :high_sierra

  resource 'completion' do
    url 'https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux'
    sha256 'b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f'
  end

  def install
    fps = build.with?('fps-60') ? 60 : 20

    redraw_interval = (1_000_000.0 / fps).round
    inreplace 'tty.c' do |s|
      s.gsub!(/^#define TTY_BLOCK_INTERVAL .*$/, "#define TTY_BLOCK_INTERVAL (#{redraw_interval} /* #{fps} fps */)")
    end

    system('sh', 'autogen.sh') if build.head?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    args << '--enable-utf8proc' if OS.mac? && MacOS.version >= :high_sierra

    ENV.append 'LDFLAGS', '-lresolv'
    system './configure', *args

    system 'make', 'install'

    pkgshare.install 'example_tmux.conf'
    bash_completion.install resource('completion')
  end

  def caveats
    <<~OUTPUT
      Example configuration has been installed to:
        #{opt_pkgshare}
    OUTPUT
  end

  test do
    system "#{bin}/tmux", '-V'
  end
end

# Deprecate ARGV
# https://github.com/Homebrew/brew/issues/1803
# https://github.com/Homebrew/brew/issues/7093
# https://github.com/Homebrew/brew/issues/5730
# https://github.com/Homebrew/brew/pull/6857
# Even Homebrew.args is private?
