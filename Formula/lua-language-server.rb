class LuaLanguageServer < Formula
  desc "Language Server for Lua and coded by Lua, the sumneko.lua ext for VSCode"
  homepage "https://github.com/sumneko/lua-language-server"
  version "2.3.7"
  url "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/sumneko/vsextensions/lua/#{version}/vspackage"
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

  # TODO: build from source, skip prebuilt
  #  https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)

  def install
    # the vsix is in fact tar.gz
    system "tar", "-xvf", "sumneko.lua-#{version}.vsix"
    if OS.mac?
      bin.install "extension/server/bin/macOS/lua-language-server"
      lib.install Dir["extension/server/bin/macOS/*.so"]
    elsif OS.linux?
      bin.install "extension/server/bin/Linux/lua-language-server"
      lib.install Dir["extension/server/bin/Linux/*.so"]
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
