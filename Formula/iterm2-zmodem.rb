class Iterm2Zmodem < Formula
  desc "ZModem integration with iTerm2"
  homepage "https://github.com/laggardkernel/iterm2-zmodem"
  # rubocop: disable all
  version "1.1.0"
  url "https://github.com/laggardkernel/iterm2-zmodem/archive/v#{version}.tar.gz"
  # rubocop: enable all
  head "https://github.com/laggardkernel/iterm2-zmodem.git"

  depends_on "lrzsz"

  def install
    bin.install "bin/iterm2-zmodem-send"
    bin.install "bin/iterm2-zmodem-recv"
  end

  def caveats
    <<~EOS
      Create triggers under Profiles -> Advanced:

        Regular expression: rz waiting to receive.\\*\\*B0100
        Action: Run Silent Coprocess
        Parameters: #{HOMEBREW_PREFIX}/bin/iterm2-zmodem-send
        Instant: checked

        Regular expression: \\*\\*B00000000000000
        Action: Run Silent Coprocess
        Parameters: #{HOMEBREW_PREFIX}/bin/iterm2-zmodem-recv
        Instant: checked

      Use 'brew info item2-zmodem' to show this note again.
    EOS
  end
end
