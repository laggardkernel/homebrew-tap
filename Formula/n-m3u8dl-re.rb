class NM3u8dlRe < Formula
  desc "Cross-Platform stream downloader for DASH/HLS"
  homepage "https://github.com/nilaoda/N_m3u8DL-RE"
  version "0.0.5-beta,20221024"
  license "MIT"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_osx-arm64_#{version.to_s.split(",").second}.tar.gz"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_osx-x86_#{version.to_s.split(",").second}.tar.gz"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v#{version.to_s.split(",").first}/N_m3u8DL-RE_Beta_linux-x86_#{version.to_s.split(",").second}.tar.gz"
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
