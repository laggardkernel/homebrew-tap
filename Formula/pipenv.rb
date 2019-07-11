class Pipenv < Formula
  include Language::Python::Virtualenv

  desc "Python dependency management tool"
  homepage "https://docs.pipenv.org/"
  # url "https://files.pythonhosted.org/packages/fd/e9/01822318551caa0d62a181ba3b10f0f3757bb1e270da97165bd52db92776/pipenv-2018.11.26.tar.gz"
  # sha256 "a673e606e8452185e9817a987572b55360f4d28b50831ef3b42ac3cab3fee846"
  head "https://github.com/pypa/pipenv.git"

  depends_on "python"

  def install
    # Using the virtualenv DSL here because the alternative of using
    # write_env_script to set a PYTHONPATH breaks things.
    # https://github.com/Homebrew/homebrew-core/pull/19060#issuecomment-338397417
    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resources
    venv.pip_install buildpath

    # `pipenv` needs to be able to find `virtualenv` and `pewtwo` on PATH. So we
    # install symlinks for those scripts in `#{libexec}/tools` and create a
    # wrapper script for `pipenv` which adds `#{libexec}/tools` to PATH.
    (libexec/"tools").install_symlink libexec/"bin/pewtwo", libexec/"bin/pip",
                                      libexec/"bin/virtualenv"
    env = {
      :PATH => "#{libexec}/tools:$PATH",
    }
    (bin/"pipenv").write_env_script(libexec/"bin/pipenv", env)

    output = Utils.popen_read("SHELL=bash #{libexec}/bin/pipenv --completion")
    (bash_completion/"pipenv").write output

    output = Utils.popen_read("SHELL=zsh #{libexec}/bin/pipenv --completion")
    (zsh_completion/"_pipenv").write output
  end

  # Avoid relative paths
  def post_install
    lib_python_path = Pathname.glob(libexec/"lib/python*").first
    lib_python_path.each_child do |f|
      next unless f.symlink?

      realpath = f.realpath
      rm f
      ln_s realpath, f
    end
    inreplace lib_python_path/"orig-prefix.txt",
              Formula["python"].opt_prefix, Formula["python"].prefix.realpath

    system libexec/"bin/pip", "install", "-U", "certifi"
    system libexec/"bin/pip", "install", "-U", "virtualenv"
    system libexec/"bin/pip", "install", "-U", "virtualenv-clone"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_match "Commands", shell_output("#{bin}/pipenv")
    system "#{bin}/pipenv", "install", "requests"
    system "#{bin}/pipenv", "install", "boto3"
    assert_predicate testpath/"Pipfile", :exist?
    assert_predicate testpath/"Pipfile.lock", :exist?
    assert_match "requests", (testpath/"Pipfile").read
    assert_match "boto3", (testpath/"Pipfile").read
  end
end
