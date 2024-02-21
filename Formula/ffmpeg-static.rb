class FfmpegStatic < Formula
  version "6.1.1"
  version_str = version.to_s
  version_without_dot = "#{version}".delete(".")
  revision 1
  desc "ffmpeg static build for macOS"

  # Use arm build from osxexperts, intel build from evermeet.
  if OS.mac? && Hardware::CPU.intel?
    homepage "https://evermeet.cx/ffmpeg/"
    url "https://evermeet.cx/ffmpeg/ffmpeg-#{version_str}.7z"

    resource "ffprobe" do
      url "https://evermeet.cx/ffmpeg/ffprobe-#{version_str}.7z"
    end

    resource "ffplay" do
      url "https://evermeet.cx/ffmpeg/ffplay-#{version_str}.7z"
    end
  elsif OS.mac? && Hardware::CPU.arm?
    homepage "https://osxexperts.net/"
    arch = Hardware::CPU.intel? ? "intel" : "arm"
    url "https://www.osxexperts.net/ffmpeg#{version_without_dot}#{arch}.zip"

    resource "ffprobe" do
      url "https://www.osxexperts.net/ffprobe#{version_without_dot}#{arch}.zip"
    end

    resource "ffplay" do
      url "https://www.osxexperts.net/ffplay#{version_without_dot}#{arch}.zip"
    end
  end

  livecheck do
    # TODO: customize livecheck to check both builds
    # Intel build is delayed after arm from osxexperts, use evermeet's build for intel
    url "https://osxexperts.net/"
    regex(/>Download ffmpeg v?(\d+(?:\.\d+)+)(\s\(Apple\s+Silicon\))/i)
  end

  def install
    bin.install "ffmpeg" => "ffmpeg-static"
    ["ffprobe", "ffplay"].each do |f|
      resource("#{f}").stage do
        bin.install "#{f}" => "#{f}-static"
      end
    end
    prefix.install_metafiles
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
# - https://github.com/eugeneware/ffmpeg-static
# - https://evermeet.cx/ffmpeg/ x86 build
# - https://osxexperts.net/ arm build
