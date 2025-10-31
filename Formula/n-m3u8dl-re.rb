class NM3u8dlRe < Formula
  desc "Cross-Platform stream downloader for DASH/HLS"
  homepage "https://github.com/nilaoda/N_m3u8DL-RE"
  version "0.5.1-beta,20251029"
  license "MIT"

  livecheck do
    url :stable
    regex(%r{N_m3u8DL-RE[^"/]+?(\d{8,})[^"/]+}i)
    strategy :github_latest do |json, regex|
      asset = json["assets"]&.first
      return if asset.nil?

      match = asset["name"]&.match(regex)
      "#{json["tag_name"].delete_prefix("v")},#{match[1]}" if match
    end
  end

  os_name = OS.mac? ? "osx" : "linux"
  if Hardware::CPU.intel?
    cpu_arch = "x64"
  elsif Hardware::CPU.arm?
    cpu_arch = "arm64"
  end
  basename = "N_m3u8DL-RE_v#{version.to_s.split(",").first}_#{os_name}-#{cpu_arch}_#{version.to_s.split(",").second}.tar.gz"
  url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/#{basename}"

  def bin_name
    "N_m3u8DL-RE"
  end

  def install
    bin.install Dir.glob("**/#{bin_name}")[0]
    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      Check https://github.com/nilaoda/N_m3u8DL-RE for usage.
    EOS
  end

  test do
    system bin/bin_name.to_s, "--help"
  end
end
