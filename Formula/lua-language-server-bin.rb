class LuaLanguageServerBin < Formula
  desc "Language Server for Lua and coded by Lua, the sumneko.lua ext for VSCode"
  homepage "https://github.com/sumneko/lua-language-server"
  version "3.8.3"
  license "MIT"

  livecheck do
    # The author doesn't do a regular release in GitHub, grab update from
    #  VSCode marketplace or corresponding sumneko/vscode-lua repo.
    url "https://github.com/sumneko/vscode-lua/releases"
    regex(%r{releases/tag/v?(\d+(?:\.\d+)+)}i)
    strategy :page_match do |page, regex|
      # page.scan(regex).map { |match| match&.first }
      page.scan(regex).flatten.uniq
    end
  end

  conflicts_with "lua-language-server", because: "they are variants of the same formula"

  head do
    # Clone to get submodules. Note git repo is not cloned into a sub-folder.
    url "https://github.com/sumneko/lua-language-server.git", branch: "master"
    depends_on "ninja" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    url "https://github.com/sumneko/lua-language-server.git", tag: version.to_s
    depends_on "ninja" => :build
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/sumneko/vscode-lua/releases/download/v#{version}/vscode-lua-v#{version}-darwin-arm64.vsix"
    # # Could easily reach rate limit with following API
    # url "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/sumneko/vsextensions/lua/v#{version}/vspackage",
    #   referer: "https://marketplace.visualstudio.com/items?itemName=sumneko.lua"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/sumneko/vscode-lua/releases/download/v#{version}/vscode-lua-v#{version}-darwin-x64.vsix"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/sumneko/vscode-lua/releases/download/v#{version}/vscode-lua-v#{version}-linux-x64.vsix"
  end

  def install
    if build.without?("prebuilt") || build.head?
      cd "./3rd/luamake" do
        # Skip broken test. https://github.com/actboy168/bee.lua/issues/19
        # HOME is /private/tmp/lua-language-server-*/.brew_home during compiling.
        inreplace "./3rd/bee.lua/test/test_filesystem.lua" do |s|
          s.gsub! "function test_fs:test_appdata_path()", "function appdata_path()"
        end
        # Don't follow the official guide to use "./compile/install.sh", which
        #  modifies the shell init files.
        if OS.mac?
          system "ninja", "-f", "compile/ninja/macos.ninja"
        elsif OS.linux?
          system "ninja", "-f", "compile/ninja/linux.ninja"
        end
      end
      system "./3rd/luamake/luamake", "rebuild"
      mkdir_p "./extension/server/"
      [
        "bin",
        "locale",
        "meta",
        "script",
        "debugger.lua",
        "main.lua",
      ].each do |s|
        cp_r "./#{s}", "./extension/server"
      end
    else
      # the vsix is in fact zip. [sumneko.]lua-#{version}.vsix
      system "unzip", Dir["*lua-*#{version}*.vsix"][0], "-d", "."
    end

    libexec.install Dir["extension/server/*"]
    Dir.chdir("extension") do
      prefix.install_metafiles
    end

    # TODO: use mktemp for logpath?
    (buildpath/"wrapper").write <<~EOS
      #!/bin/sh
      # https://github.com/sumneko/lua-language-server/wiki/Command-line
      exec \\
        #{libexec}/bin/lua-language-server \\
        # -E #{libexec}/main.lua \\
        # --metapath=#{libexec}/meta \\
        --logpath=#{var}/log/lua-language-server \\
        "$@"
    EOS
    bin.install buildpath/"wrapper" => "lua-language-server"
  end

  def post_install
    (var/"log/lua-language-server").mkpath
    chmod 0755, var/"log/lua-language-server"
  end

  def caveats
    <<~EOS
      This Lua language server has official support as a VSCode extension,
        https://marketplace.visualstudio.com/items?itemName=sumneko.lua
      For use without VSCode, check here for detail:
        https://github.com/sumneko/lua-language-server/wiki/Setting

      A wrapper is provided as #{HOMEBREW_PREFIX}/bin/lua-language-server
      to use brew compatible log directory.
    EOS
  end

  test do
    require "pty"
    output = /^Content-Length: \d+\s*$/

    stdout, stdin, lua_ls = PTY.spawn bin/"lua-language-server"
    sleep 5
    stdin.write "\n"
    sleep 25
    assert_match output, stdout.readline
  ensure
    Process.kill "TERM", lua_ls
    Process.wait lua_ls
  end
end
# - https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
# - https://github.com/saadparwaiz1/homebrew-personal/blob/main/Formula/lua-language-server.rb
# - bin/{os_name} folder doesn't exist in 2.5.4+
