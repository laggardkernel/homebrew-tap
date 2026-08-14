class FfmpegStatic < Formula
  desc "Static FFmpeg build"
  homepage "https://osxexperts.net/"
  # Display version and filename token disagree on osxexperts.net.
  # e.g. "Download ffmpeg 9.0" links to ffmpeg9arm.zip, not ffmpeg90arm.zip.
  version "9.0,9"
  download_version = version.to_s.split(",", 2).second
  url "https://www.osxexperts.net/ffmpeg#{download_version}arm.zip"

  depends_on arch: :arm64
  depends_on :macos

  resource "ffprobe" do
    url "https://www.osxexperts.net/ffprobe#{download_version}arm.zip"
  end

  resource "ffplay" do
    url "https://www.osxexperts.net/ffplay#{download_version}arm.zip"
  end

  livecheck do
    url :homepage
    regex(/href="[^">]*ffmpeg(\d+)arm\.zip"[^>]*>\s*Download\s+ffmpeg\s+v?(\d+(?:\.\d+)+)/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| "#{match.second},#{match.first}" }
    end
  end

  def install
    bin.install "ffmpeg" => "ffmpeg-static"
    ["ffprobe", "ffplay"].each do |f|
      resource(f.to_s).stage do
        bin.install f.to_s => "#{f}-static"
      end
    end
    prefix.install_metafiles
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg-static", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_path_exists mp4out
  end
end
# - https://github.com/eugeneware/ffmpeg-static
# - https://evermeet.cx/ffmpeg/ x86 build
# - https://osxexperts.net/ arm build
