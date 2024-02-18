class FfmpegStatic < Formula
  version "6.1.1"
  version_without_dot = "#{version}".delete(".")
  arch = Hardware::CPU.intel? ? "intel" : "arm"
  # sha256 ""

  homepage "https://osxexperts.net/"
  desc "ffmpeg static build for macOS"
  url "https://www.osxexperts.net/ffmpeg#{version_without_dot}#{arch}.zip"

  livecheck do
    # Intel build is delayed after arm build.
    url "https://osxexperts.net/"
    regex(/>Download ffmpeg v?(\d+(?:\.\d+)+)(\s\(Intel\))/i)
  end

  def install
    bin.install "ffmpeg" => "ffmpeg-static"
    prefix.install_metafiles
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
# https://github.com/eugeneware/ffmpeg-static
