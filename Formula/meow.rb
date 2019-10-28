require "language/go"

class Meow < Formula
  desc "MEOW, a fork of proxy COW using whitelist mode"
  homepage "https://github.com/netheril96/MEOW"
  head "https://github.com/netheril96/MEOW.git"
  # No newer release yet.
  # url "https://github.com/netheril96/MEOW/archive/1.5.tar.gz"
  # sha256 "5c5244f0ab539550c0e350b348245d2add599237af217152604ee126c6a866a3"

  depends_on "go" => :build

  go_resource "github.com/aead/chacha20" do
    url "https://github.com/aead/chacha20.git",
      :revision => "8b13a72661dae6e9e5dea04f344f0dc95ea29547"
  end

  go_resource "github.com/cyfdecyf/bufio" do
    url "https://github.com/cyfdecyf/bufio.git",
      :revision => "9601756e2a6b5fa8ca6749ce4f73f6afdd83030d"
  end

  go_resource "github.com/cyfdecyf/color" do
    url "https://github.com/cyfdecyf/color.git",
      :revision => "31d518c963d22b95d500ab628c1d1d1b8eff2ab9"
  end

  go_resource "github.com/cyfdecyf/leakybuf" do
    url "https://github.com/cyfdecyf/leakybuf.git",
      :revision => "ffae040843bee2891b6306d1d085c25ca822e72c"
  end

  go_resource "github.com/shadowsocks/shadowsocks-go" do
    url "https://github.com/shadowsocks/shadowsocks-go.git",
      :revision => "6a03846ca9c02d8e94142b3c72b3182207a414b4"
  end

  go_resource "golang.org/x/crypto" do
    url "https://go.googlesource.com/crypto.git",
      :revision => "87dc89f01550277dc22b74ffcf4cd89fa2f40f4c"
  end

  go_resource "golang.org/x/sys" do
    url "https://go.googlesource.com/sys.git",
      :revision => "f8518d3b3627146e88bd43ca73045e1b8d8eb6c6"
  end

  def install
    ENV["GOPATH"] = buildpath
    path = buildpath/"src/github.com/netheril96/MEOW"
    path.install Dir["*"]
    Language::Go.stage_deps resources, buildpath/"src"

    cd path do
      system "go", "build", "-o", bin/"meow"

      prefix.install_metafiles
    end
  end

  test do
    system bin/"meow", "--help"
  end

  def caveats; <<~EOS
    MEOW forwards connections to proxy or does direct connect according to
    geolocation of the IP address.

    Config file defaults to $HOME/.meow/rc on Unix, ./rc.txt on Windows.

    Check the homepage for config format,

      https://github.com/netheril96/MEOW

  EOS
  end

end
