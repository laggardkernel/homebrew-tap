class RimeWanxiangUpdate < Formula
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

  depends_on "python"

  def install
    puts "Patch config file as ~/.config/#{name}/settings.ini"
    entry_script = "Python-全平台版本/Python/rime-wanxiang-update-all.py"
    inreplace entry_script do |s|
      s.gsub!(/self.config_path = .+$/, "self.config_path = os.path.join(os.path.expanduser('~'), '.config/#{name}/settings.ini')")
    end

    with_env(
      PIP_PYTHON:       libexec/"bin/python",
      PIP_NO_CACHE_DIR: "1", # avoid reusing former build pkgs like mysqlclient
    ) do
      # Similar to 'virtualenv_install_with_resources' but omitting params
      #  like '--no-deps', '--without-pip'. Inject pip into venv for `dae update_cli`.
      system "python", "-m", "venv", "--system-site-packages", libexec.to_s
      system "python", "-m", "pip", "install", "requests", "tqdm"
    end

    puts "Create script #{name}"
    bin.mkdir
    cp "#{entry_script}", bin/"#{name}"
    chmod 0755, bin/"#{name}"
    inreplace bin/"#{name}" do |s|
      s.gsub!(/\A/, "#!#{libexec}/bin/python\n")
    end

    cp "Python-全平台版本/README.md", prefix/"README.md"
    # prefix.install_metafiles is run by force, and overwrite our copy.
  end
end
