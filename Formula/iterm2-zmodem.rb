class Iterm2Zmodem < Formula
  desc "ZModem integration with iTerm2"
  homepage "https://github.com/laggardkernel/iterm2-zmodem"
  url "https://github.com/laggardkernel/iterm2-zmodem/archive/v1.0.0.tar.gz"
  sha256 "4a19e2f97abf11ed0a6f80d575198a1bd0e44a6d907b1b9017a2dc537a0cfcf9"
  head "https://github.com/laggardkernel/iterm2-zmodem.git"

  bottle :unneeded

  depends_on "lrzsz"

  def install
    bin.install "bin/iterm2-zmodem-send"
    bin.install "bin/iterm2-zmodem-recv"
  end

  def caveats
    <<~EOS
      Create triggers under Profiles -> Advanced:

        Regular expression: rz waiting to receive.\*\*B0100
        Action: Run Silent Coprocess
        Parameters: #{HOMEBREW_PREFIX}/bin/iterm2-zmodem-send
        Instant: checked

        Regular expression: \*\*B00000000000000
        Action: Run Silent Coprocess
        Parameters: #{HOMEBREW_PREFIX}/bin/iterm2-zmodem-recv
        Instant: checked
    EOS
  end
end
