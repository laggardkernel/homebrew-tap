class LuaLanguageServer < Formula
  desc "Language Server for Lua and coded by Lua, the sumneko.lua ext for VSCode"
  homepage "https://github.com/sumneko/lua-language-server"
  version "2.4.11"
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

  head do
    # Clone to get submodules. Note git repo is not cloned into a sub-folder.
    url "https://github.com/sumneko/lua-language-server.git", branch: "master"
    depends_on "ninja" => :build
  end

  option "without-prebuilt", "Skip prebuilt binary and build from source"

  if build.without?("prebuilt")
    url "https://github.com/sumneko/lua-language-server.git", tag: version.to_s
    depends_on "ninja" => :build
  else
    url "https://github.com/sumneko/vscode-lua/releases/download/v#{version}/lua-#{version}.vsix"
    # # Could easily reach rate limit with following API
    # url "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/sumneko/vsextensions/lua/#{version}/vspackage",
    #   referer: "https://marketplace.visualstudio.com/items?itemName=sumneko.lua"
  end

  def install
    if build.without?("prebuilt") || build.head?
      cd "./3rd/luamake" do
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
        "platform.lua",
      ].each do |s|
        cp_r "./#{s}", "./extension/server"
      end
    else
      # the vsix is in fact tar.gz. [sumneko.]lua-#{version}.vsix
      system "tar", "-xvf", Dir["*lua-#{version}.vsix"][0]
    end

    if OS.mac?
      cd "extension/server/bin/macOS" do
        bin.install "lua-language-server"
        lib.install Dir["*.so"]
      end
    elsif OS.linux?
      cd "extension/server/bin/Linux" do
        bin.install "lua-language-server"
        lib.install Dir["*.so"]
      end
    end
    rm_rf "extension/server/bin"
    share.install "extension/server" => "lua-language-server"
    Dir.chdir("extension") do
      prefix.install_metafiles
    end
  end

  def caveats
    <<~EOS
      This Lua language server has official support as a VSCode extension,
        https://marketplace.visualstudio.com/items?itemName=sumneko.lua
      For use without VSCode, check here for detail:
        https://github.com/sumneko/lua-language-server/wiki/Setting-without-VSCode
    EOS
  end

  test do
    system "#{bin}/lua-language-server", "-v"
  end
end
# - https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
# - https://github.com/saadparwaiz1/homebrew-personal/blob/main/Formula/lua-language-server.rb
