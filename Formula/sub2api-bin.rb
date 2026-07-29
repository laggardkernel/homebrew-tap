class Sub2apiBin < Formula
  desc "AI API gateway platform for managing subscription quotas"
  homepage "https://github.com/Wei-Shaw/sub2api"
  version = "0.1.170"
  license "LGPL-3.0-only"

  os_name = OS.mac? ? "darwin" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "amd64"
  url "https://github.com/Wei-Shaw/sub2api/releases/download/v#{version}/sub2api_#{version}_#{os_name}_#{cpu_arch}.tar.gz"

  livecheck do
    url "https://github.com/Wei-Shaw/sub2api/releases" # rubocop: disable all
    regex(%r{href=.*?/releases/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match do |page, regex|
      page.scan(regex).flatten.uniq
    end
  end

  def install
    bin.install "sub2api"
    prefix.install_metafiles

    (etc/"sub2api").install "deploy/config.example.yaml"
  end

  def post_install
    (var/"sub2api").mkpath
    chmod 0755, var/"sub2api"
    (var/"log/sub2api").mkpath
    chmod 0755, var/"log/sub2api"
  end

  def caveats
    <<~EOS
      Sub2API needs PostgreSQL and Redis for normal operation.

      Paths used by this formula:

        config:  #{etc}/sub2api/config.yaml
        data:    #{var}/sub2api

      Upstream has no CLI flag for config path. Use env vars:

        CONFIG_FILE  absolute path to config.yaml
        DATA_DIR     runtime data directory

      First run (setup wizard):

        brew services start sub2api-bin
        open http://localhost:8080

      Manual config instead of the wizard:

        cp #{etc}/sub2api/config.example.yaml #{etc}/sub2api/config.yaml
        $EDITOR #{etc}/sub2api/config.yaml

      Manual run:

        CONFIG_FILE=#{etc}/sub2api/config.yaml \\
        DATA_DIR=#{var}/sub2api \\
        sub2api
    EOS
  end

  service do
    run [opt_bin/"sub2api"]
    keep_alive successful_exit: true
    working_dir var/"sub2api"
    environment_variables CONFIG_FILE: "#{etc}/sub2api/config.yaml",
                          DATA_DIR:    "#{var}/sub2api"
  end

  test do
    assert_match "Sub2API #{version}", shell_output("#{bin}/sub2api -version 2>&1")
  end
end
