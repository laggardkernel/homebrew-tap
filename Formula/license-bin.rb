class LicenseBin < Formula
  desc "Command-line license text generator"
  homepage "https://github.com/nishanths/license"
  version "5.0.4"
  license "MIT"
  head "https://github.com/nishanths/license.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : "linux"
  if Hardware::CPU.arm?
    cpu_arch = "arm64"
  else
    cpu_arch = "amd64"
  end
  basename = "license-v#{version}-#{os_name}-#{cpu_arch}"
  url "https://github.com/nishanths/license/releases/download/v#{version}/#{basename}"

  def install
    bin.install Dir.glob("license*")[0] => "license"
  end

  test do
    help_output = shell_output("#{bin}/license -list")
    assert_match "agpl-3.0      (GNU Affero General Public License v3.0)", help_output

    (testpath/"LICENSE.test").write <<~EOS
      BSD 2-Clause License

      Copyright (c) 2009-present, Homebrew contributors
      All rights reserved.

      Redistribution and use in source and binary forms, with or without
      modification, are permitted provided that the following conditions are met:

      1. Redistributions of source code must retain the above copyright notice, this
         list of conditions and the following disclaimer.

      2. Redistributions in binary form must reproduce the above copyright notice,
         this list of conditions and the following disclaimer in the documentation
         and/or other materials provided with the distribution.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
      DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
      FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
      DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
      SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
      CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
      OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    EOS

    system bin/"license", "-o", "LICENSE.txt", "-n", "Homebrew contributors", "-y", "2009-present", "bsd-2-clause"
    assert_match File.read("LICENSE.test"), File.read("LICENSE.txt")
  end
end
