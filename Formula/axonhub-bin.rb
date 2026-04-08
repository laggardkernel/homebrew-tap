class AxonhubBin < Formula
  desc "OpenAI-compatible API gateway for coding agents and LLM clients"
  homepage "https://github.com/looplj/axonhub"
  version "0.9.31"
  license "Apache-2.0"

  os_name = OS.mac? ? "darwin" : "linux"
  cpu_arch = Hardware::CPU.arm? ? "arm64" : "amd64"
  basename = "axonhub_#{version}_#{os_name}_#{cpu_arch}.zip"
  url "https://github.com/looplj/axonhub/releases/download/v#{version}/#{basename}"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    bin.install "axonhub"

    config_temp = buildpath/"config.yml"
    config_temp.write <<~YAML
      server:
        port: 8090
        name: "AxonHub"
        debug: false

      db:
        dialect: "sqlite3"
        dsn: "#{var}/lib/axonhub/axonhub.db?cache=shared&_fk=1"

      cache:
        mode: "memory"
        memory:
          expiration: "5s"
          cleanup_interval: "10m"

      log:
        level: "info"
        encoding: "json"
        output: "file"
        file:
          path: "#{var}/log/axonhub/axonhub.log"
          max_size: 100
          max_age: 30
          max_backups: 10
          local_time: true
    YAML

    (etc/"axonhub").mkpath
    config_path = etc/"axonhub"
    dst_default = config_path/"config.yml.default"
    rm dst_default if dst_default.exist?
    if (config_path/"config.yml").exist?
      config_path.install config_temp => "config.yml.default"
    else
      config_path.install config_temp => "config.yml"
    end
  end

  def post_install
    (var/"lib/axonhub").mkpath
    chmod 0755, var/"lib/axonhub"

    # (var/"log/axonhub").mkpath
    # chmod 0755, var/"log/axonhub"
  end

  def caveats
    <<~EOS
      Config file:
        #{etc}/axonhub/config.yml

      Data directory:
        #{var}/lib/axonhub

      Start service:
        brew services start #{name}

      Example config: https://github.com/looplj/axonhub/blob/release/v0.9.x/config.example.yml
    EOS
  end

  service do
    run [opt_bin/"axonhub"]
    keep_alive true
    # Axonhub doesn't support specify config file thru command line, instead
    #  search for config.yml file in order. The first is $PWD/config.yml.
    working_dir etc/"axonhub"
    # Axonhub has builtin logging system.
    # log_path var/"log/axonhub/run.log"
    # error_log_path var/"log/axonhub/run.log"
  end

  test do
    (testpath/"config.yml").write <<~YAML
      server:
        port: 18090
    YAML
    assert_equal "18090", shell_output("#{bin}/axonhub config get server.port").chomp
    assert_match version.to_s, shell_output("#{bin}/axonhub version")
  end
end
