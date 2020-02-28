class TmuxOptions < Formula
  desc "Terminal multiplexer with higher FPS"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.0a/tmux-3.0a.tar.gz"
  sha256 "4ad1df28b4afa969e59c08061b45082fdc49ff512f30fc8e43217d7b0e5f8db9"

  bottle :unneeded

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
  end

  def install
    inreplace "tty.c" do |s|
      s.gsub! /^#define TTY_BLOCK_INTERVAL .*$/, '#define TTY_BLOCK_INTERVAL (33333 /* 30fps */)'
    end

    system "sh", "autogen.sh" if build.head?

    args = %W[
      --disable-Dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats; <<~EOS
    Example configuration has been installed to:
      #{opt_pkgshare}
  EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
