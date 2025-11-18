class LibrimeCloudBin < Formula
  desc "Rime Cloud Pinyin Plugin"
  homepage "https://github.com/hchunhui/librime-cloud"
  version 'latest'

  os_name = OS.mac? ? "macos" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
  basename = "#{os_name}-#{cpu_arch}-lua5.4.tar.gz"
  url "https://github.com/hchunhui/librime-cloud/releases/download/continuous/#{basename}"

  livecheck do
    skip "Contiuous build"
  end

  # TODO(lk): build from source
  def install
    lib_dst = lib/"librime-cloud"
    mkdir_p lib_dst
    lib_dst.install Dir["out-*/*"]
    lib_dst.install Dir["scripts/lua/*"]

    share_dst = share/"librime-cloud"
    mkdir_p share_dst
    share_dst.install Dir["scripts/*"]

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      Follow instructions from https://github.com/hchunhui/librime-cloud/issues/17
      for setup. Disable qurantine for the libs manually:

      sudo xattr -dr com.apple.quarantine #{lib}/librime-cloud/*.so

      Add the lib path into rime.lua:

      package.path = package.path .. ";#{lib}/librime-cloud/?.lua"
      package.cpath = package.cpath .. ";#{lib}/librime-cloud/?.so"
    EOS
  end
end
