class VimOptions < Formula
  desc "Vi 'workalike' with many additional features"
  homepage "https://www.vim.org/"
  # vim should only be updated every 25 releases on multiples of 25
  url "https://github.com/vim/vim/archive/v8.2.2500.tar.gz"
  sha256 "df3028fd4d375068c8119d76e476381703c99a7379cc4028c2c15d541393734d"
  license "Vim"
  head "https://github.com/vim/vim.git"

  bottle do
    sha256 arm64_big_sur: "412086ac24b6b9da1d3d612abea3f0475ee6999918e138c3f2728db5c7a331b2"
    sha256 big_sur:       "e54a58c050bd5df985c293cc301cf7827560901d232ccdc5d70f223874caeabb"
    sha256 catalina:      "14f56cecb36ff9020110db1497a754bd0cb95c6071faa38bd766f1058071a06d"
    sha256 mojave:        "bd27615ff5264d44774e962bb0f5c26696ec85e2ce51849c8adec7ed2d6d71ae"
  end

  option "with-override-system-vi", "Override system vi"
  option "with-gettext", "Build vim with National Language Support (translated messages, keymaps)"
  option "with-client-server", "Enable client/server mode"

  LANGUAGES_OPTIONAL = %w[lua python@2 tcl].freeze
  LANGUAGES_DEFAULT  = %w[python].freeze

  option "with-python@2", "Build vim with python@2 instead of python[3] support"
  LANGUAGES_OPTIONAL.each do |language|
    option "with-#{language}", "Build vim with #{language} support"
  end
  LANGUAGES_DEFAULT.each do |language|
    option "without-#{language}", "Build vim without #{language} support"
  end

  deprecated_option "override-system-vi" => "with-override-system-vi"

  depends_on "perl"
  depends_on "ruby"
  depends_on :x11 if build.with? "client-server"
  depends_on "python" => :recommended if build.without? "python@2"
  depends_on "gettext" => :optional
  depends_on "lua" => :optional
  depends_on "luajit" => :optional
  depends_on "python@2" => :optional

  conflicts_with "ex-vi",
    :because => "vim and ex-vi both install bin/ex and bin/view"

  conflicts_with "macvim",
    :because => "vim and macvim both install vi* binaries"

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"

    # https://github.com/Homebrew/homebrew-core/pull/1046
    ENV.delete("SDKROOT")

    # vim doesn't require any Python package, unset PYTHONPATH.
    ENV.delete("PYTHONPATH")

    opts = ["--enable-perlinterp", "--enable-rubyinterp"]

    (LANGUAGES_OPTIONAL + LANGUAGES_DEFAULT).each do |language|
      feature = { "python" => "python3", "python@2" => "python" }
      if build.with? language
        opts << "--enable-#{feature.fetch(language, language)}interp"
      end
    end

    if opts.include?("--enable-pythoninterp") && opts.include?("--enable-python3interp")
      # only compile with either python or python@2 support, but not both
      # (if vim74 is compiled with +python3/dyn, the Python[3] library lookup segfaults
      # in other words, a command like ":py3 import sys" leads to a SEGV)
      opts -= %w[--enable-python3interp]
    end

    opts << "--disable-nls" if build.without? "gettext"
    opts << "--enable-gui=no"

    if build.with? "client-server"
      opts << "--with-x"
    else
      opts << "--without-x"
    end

    if build.with?("lua") || build.with?("luajit")
      opts << "--enable-luainterp"

      if build.with? "luajit"
        opts << "--with-luajit"
        opts << "--with-lua-prefix=#{Formula["luajit"].opt_prefix}"
      else
        opts << "--with-lua-prefix=#{Formula["lua"].opt_prefix}"
      end

      if build.with?("lua") && build.with?("luajit")
        onoe <<~EOS
          Vim will not link against both Luajit & Lua simultaneously.
          Proceeding with Lua.
        EOS
        opts -= %w[--with-luajit]
      end
    end

    # We specify HOMEBREW_PREFIX as the prefix to make vim look in the
    # the right place (HOMEBREW_PREFIX/share/vim/{vimrc,vimfiles}) for
    # system vimscript files. We specify the normal installation prefix
    # when calling "make install".
    # Homebrew will use the first suitable Perl & Ruby in your PATH if you
    # build from source. Please don't attempt to hardcode either.
    system "./configure", "--prefix=#{HOMEBREW_PREFIX}",
                          "--mandir=#{man}",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--with-compiledby=Homebrew",
                          "--enable-cscope",
                          "--enable-terminal",
                          *opts
    system "make"
    # Parallel install could miss some symlinks
    # https://github.com/vim/vim/issues/1031
    ENV.deparallelize
    # If stripping the binaries is enabled, vim will segfault with
    # statically-linked interpreters like ruby
    # https://github.com/vim/vim/issues/114
    system "make", "install", "prefix=#{prefix}", "STRIP=#{which "true"}"
    bin.install_symlink "vim" => "vi" if build.with? "override-system-vi"
  end

  test do
    if build.with? "python@2"
      (testpath/"commands.vim").write <<~EOS
        :python import vim; vim.current.buffer[0] = 'hello world'
        :wq
      EOS
      system bin/"vim", "-T", "dumb", "-s", "commands.vim", "test.txt"
      assert_equal "hello world", File.read("test.txt").chomp
    elsif build.with? "python"
      (testpath/"commands.vim").write <<~EOS
        :python3 import vim; vim.current.buffer[0] = 'hello python3'
        :wq
      EOS
      system bin/"vim", "-T", "dumb", "-s", "commands.vim", "test.txt"
      assert_equal "hello python3", File.read("test.txt").chomp
    end
    if build.with? "gettext"
      assert_match "+gettext", shell_output("#{bin}/vim --version")
    end
  end
end
