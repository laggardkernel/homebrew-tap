class WanxiangUpdate < Formula
  desc "Updater script for wanxiang input method"
  homepage "https://github.com/rimeinn/rime-wanxiang-update-tools"
  # rubocop: disable all
  version "090104a"
  url "https://github.com/rimeinn/rime-wanxiang-update-tools/archive/#{version}.tar.gz"
  # rubocop: enable all
  license "MIT"

  livecheck do
    url "https://github.com/rimeinn/rime-wanxiang-update-tools/commits/main/Python-全平台版本/Python/rime-wanxiang-update-all.py"
    regex(%r{href="/rimeinn/rime-wanxiang-update-tools/tree/([a-z0-9]{7,}+)" }i)
    strategy :page_match do |page, regex|
      # Only return the 1st commit to avoid alphabetical version comparison
      page.scan(regex).flatten.first&.slice!(0..6)
    end
  end

  # depends_on "python"

  def install
    lib_dst = libexec/"wanxiang-update"
    mkdir_p lib_dst
    lib_dst.install "Python-全平台版本/Python/rime-wanxiang-update-all.py"

    # TODO(lk): waiting the script support custom 'settings.ini' path
    config_path = etc/"wanxiang-update"
    mkdir_p config_path.to_s

    (bin/"wanxiang-update").write <<~EOS
      #!/bin/bash
      PWD="#{config_path}" python3 "#{lib_dst}/rime-wanxiang-update-all.py"
    EOS
    chmod 0755, bin/"wanxiang-update"

    prefix.install_metafiles
  end
end
