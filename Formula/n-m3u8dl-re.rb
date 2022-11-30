class NM3u8dlRe < Formula
  desc "Cross-Platform stream downloader for DASH/HLS"
  homepage "https://github.com/nilaoda/N_m3u8DL-RE"
  version "0.1.3-beta,20221129"
  license "MIT"

  livecheck do
    # Assets section is loaded by js nowadays, use api resp
    url "https://api.github.com/repos/nilaoda/N_m3u8DL-RE/releases"
    regex(%r{https.*?/releases/download/v?(\d+(?:\.\d+)+(-[^"/]+)?)/N_m3u8DL-RE[^"/]+?(\d{8})[^"/]+"}i)
    strategy :page_match do |page|
      page.scan(regex).map { |match| match&.first + "," + match&.third }
    end
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_osx-arm64_#{version.to_s.split(",").second}.tar.gz"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_osx-x64_#{version.to_s.split(",").second}.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_linux-x64_#{version.to_s.split(",").second}.tar.gz"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_linux-arm64_#{version.to_s.split(",").second}.tar.gz"
  end

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
    system "#{bin}/#{bin_name}", "--help"
  end
end
