class FfmpegStatic < Formula
  desc "Ffmpeg static build" # rubocop: disable all
  homepage "https://osxexperts.net"
  version "7.1.1"
  version_str = version.to_s
  version_without_dot = version.to_s.delete(".").gsub(/0+$/, "")

  # Use arm build from osxexperts, intel build from evermeet.
  arch = Hardware::CPU.intel? ? "intel" : "arm"
  if OS.mac? && Hardware::CPU.arm?
    homepage "https://osxexperts.net/"
    url "https://www.osxexperts.net/ffmpeg#{version_without_dot}#{arch}.zip"

    resource "ffprobe" do
      url "https://www.osxexperts.net/ffprobe#{version_without_dot}#{arch}.zip"
    end

    resource "ffplay" do
      url "https://www.osxexperts.net/ffplay#{version_without_dot}#{arch}.zip"
    end
  elsif OS.mac? && Hardware::CPU.intel?
    homepage "https://evermeet.cx/ffmpeg/"
    url "https://evermeet.cx/ffmpeg/ffmpeg-#{version_str}.7z"

    resource "ffprobe" do
      url "https://evermeet.cx/ffmpeg/ffprobe-#{version_str}.7z"
    end

    resource "ffplay" do
      url "https://evermeet.cx/ffmpeg/ffplay-#{version_str}.7z"
    end
  end

  livecheck do
    # TODO: customize livecheck to check both builds
    # Intel build is delayed after arm from osxexperts, use evermeet's build for intel
    # rubocop: disable all
    url "https://osxexperts.net/"
    # rubocop: enable all
    regex(/>Download ffmpeg v?(\d+(?:\.\d+)+)(\s\(Apple\s+Silicon\))/i)
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
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
# - https://github.com/eugeneware/ffmpeg-static
# - https://evermeet.cx/ffmpeg/ x86 build
# - https://osxexperts.net/ arm build
