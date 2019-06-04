class Poetry < Formula
  include Language::Python::Virtualenv

  desc "Python dependency management and packaging tool"
  homepage "https://poetry.eustace.io/"
  url "https://files.pythonhosted.org/packages/1f/69/96862c449a3b586c16cdedd97df1c40c94569fec99c3f5fc484405013817/poetry-0.12.16.tar.gz"
  sha256 "88e14cb361d2b6f80b120ebfeffdb031484958113f5c13227d06eaf7206b9440"

  depends_on "python"

  # pip install homebrew-pypi-poet, poet poetry
  # --no-cache-dir --index-url https://pypi.org/simple
  resource "attrs" do
    url "https://files.pythonhosted.org/packages/cc/d9/931a24cc5394f19383fbbe3e1147a0291276afa43a0dc3ed0d6cd9fda813/attrs-19.1.0.tar.gz"
    sha256 "f0b870f674851ecbfbbbd364d6b5cbdff9dcedbc7f3f5e18a6891057f21fe399"
  end

  resource "CacheControl" do
    url "https://files.pythonhosted.org/packages/5e/f0/2c193ed1f17c97ae539da7e1c2d48b80d8cccb1917163b26a91ca4355aa6/CacheControl-0.12.5.tar.gz"
    sha256 "cef77effdf51b43178f6a2d3b787e3734f98ade253fa3187f3bb7315aaa42ff7"
  end

  resource "cachy" do
    url "https://files.pythonhosted.org/packages/68/ef/eabaf6c36bb87e4c1a74790b19e44064df25e09a55f191eb71ccd2b512ad/cachy-0.2.0.tar.gz"
    sha256 "b71513e5a38ce90c1280c02b7d8d6bb3fdf64666c9cc0584f2479afea097d56c"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/06/b8/d1ea38513c22e8c906275d135818fee16ad8495985956a9b7e2bb21942a1/certifi-2019.3.9.tar.gz"
    sha256 "b26104d6835d1f5e49452a26eb2ff87fe7090b89dfcaee5ea2212697e1e1d7ae"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"
    sha256 "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"
  end

  resource "cleo" do
    url "https://files.pythonhosted.org/packages/cb/9f/8dd57785485b2a2746edbe598a31b0852740a1ff91a2739c104b628c8520/cleo-0.6.8.tar.gz"
    sha256 "85a63076b72ca376fb06668be1fc7758dc16740b394783d5cc65200c4b32f71b"
  end

  resource "html5lib" do
    url "https://files.pythonhosted.org/packages/85/3e/cf449cf1b5004e87510b9368e7a5f1acd8831c2d6691edd3c62a0823f98f/html5lib-1.0.1.tar.gz"
    sha256 "66cb0dcfdbbc4f9c3ba1a63fdb511ffdbd4f513b2b6d81b80cd26ce6b3fb3736"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"
    sha256 "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/1f/7f/a020327823b9c405ee6f85ab3053ff171e10801b19cfe55c78bb0b3810e7/jsonschema-3.0.1.tar.gz"
    sha256 "0c0a81564f181de3212efa2d17de1910f8732fa1b71c42266d983cd74304e20d"
  end

  resource "lockfile" do
    url "https://files.pythonhosted.org/packages/17/47/72cb04a58a35ec495f96984dddb48232b551aafb95bde614605b754fe6f7/lockfile-0.12.2.tar.gz"
    sha256 "6aed02de03cba24efabcd600b30540140634fc06cfa603822d508d5361e9f799"
  end

  resource "msgpack" do
    url "https://files.pythonhosted.org/packages/81/9c/0036c66234482044070836cc622266839e2412f8108849ab0bfdeaab8578/msgpack-0.6.1.tar.gz"
    sha256 "4008c72f5ef2b7936447dcb83db41d97e9791c83221be13d5e19db0796df1972"
  end

  resource "pastel" do
    url "https://files.pythonhosted.org/packages/bd/13/a68f2e448b471e8c49e9b596d569ae167a5135ac672b1dc5f24f62f9c15f/pastel-0.1.0.tar.gz"
    sha256 "3108af417ec0fa6d0a620e676ec4f02c839ca13e10611586e5d2174b46aa0bc3"
  end

  resource "pkginfo" do
    url "https://files.pythonhosted.org/packages/6c/04/fd6683d24581894be8b25bc8c68ac7a0a73bf0c4d74b888ac5fe9a28e77f/pkginfo-1.5.0.1.tar.gz"
    sha256 "7424f2c8511c186cd5424bbf31045b77435b37a8d604990b79d4e70d741148bb"
  end

  resource "pylev" do
    url "https://files.pythonhosted.org/packages/cc/61/dab2081d3d86dcf0b9f5dcfb11b256d76cd14aad7ccdd7c8dd5e7f7e41a0/pylev-1.3.0.tar.gz"
    sha256 "063910098161199b81e453025653ec53556c1be7165a9b7c50be2f4d57eae1c3"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/5d/3a/24d275393f493004aeb15a1beae2b4a3043526e8b692b65b4a9341450ebe/pyparsing-2.4.0.tar.gz"
    sha256 "1873c03321fc118f4e9746baf201ff990ceb915f433f23b395f5580d1840cb2a"
  end

  resource "pyrsistent" do
    url "https://files.pythonhosted.org/packages/8c/46/4e93ab8a379d7efe93f20a0fb8a27bdfe88942cc954ab0210c3164e783e0/pyrsistent-0.14.11.tar.gz"
    sha256 "3ca82748918eb65e2d89f222b702277099aca77e34843c5eb9d52451173970e2"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/01/62/ddcf76d1d19885e8579acb1b1df26a852b03472c0e46d2b959a714c90608/requests-2.22.0.tar.gz"
    sha256 "11e007a8a2aa0323f5a921e9e6a2d7e4e67d9877e85773fba9ba6419025cbeb4"
  end

  resource "requests-toolbelt" do
    url "https://files.pythonhosted.org/packages/86/f9/e80fa23edca6c554f1994040064760c12b51daff54b55f9e379e899cd3d4/requests-toolbelt-0.8.0.tar.gz"
    sha256 "f6a531936c6fa4c6cfce1b9c10d5c4f498d16528d2a54a22ca00011205a187b5"
  end

  resource "shellingham" do
    url "https://files.pythonhosted.org/packages/1b/82/52b4facd501d1cdfee1f2b3aa6092dc0ee6c07baf78692f9035adb1357da/shellingham-1.3.1.tar.gz"
    sha256 "985b23bbd1feae47ca6a6365eacd314d93d95a8a16f8f346945074c28fe6f3e0"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  # resource "tomlkit" do
  #   url "https://files.pythonhosted.org/packages/f7/f7/bbd9213bfe76cb7821c897f9ed74877fd74993b4ca2fe9513eb5a31030f9/tomlkit-0.5.3.tar.gz"
  #   sha256 "d6506342615d051bc961f70bfcfa3d29b6616cc08a3ddfd4bc24196f16fd4ec2"
  # end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/4c/13/2386233f7ee40aa8444b47f7463338f3cbdf00c316627558784e3f542f07/urllib3-1.25.3.tar.gz"
    sha256 "dbe59173209418ae49d485b87d1681aefa36252ee85884c31346debd19463232"
  end

  resource "webencodings" do
    url "https://files.pythonhosted.org/packages/0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47/webencodings-0.5.1.tar.gz"
    sha256 "b36a1c245f2d304965eb4e0a82848379241dc04b865afcc4aab16748587e1923"
  end

  def install
    # Using the virtualenv DSL here because the alternative of using
    # write_env_script to set a PYTHONPATH breaks things.
    # https://github.com/Homebrew/homebrew-core/pull/19060#issuecomment-338397417
    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resources
    venv.pip_install buildpath

    # install tomlkit manually
    system libexec/"bin/pip", "install", "-U", "tomlkit==0.5.3"

    # `pipenv` needs to be able to find `virtualenv` and `pewtwo` on PATH. So we
    # install symlinks for those scripts in `#{libexec}/tools` and create a
    # wrapper script for `pipenv` which adds `#{libexec}/tools` to PATH.
    (libexec/"tools").install_symlink libexec/"bin/pewtwo", libexec/"bin/pip",
                                      libexec/"bin/virtualenv"
    env = {
      :PATH => "#{libexec}/tools:$PATH",
    }
    (bin/"poetry").write_env_script(libexec/"bin/poetry", env)

    # output couldn't be catched by Utils.popen_read (non-tty)
    output = `#{libexec}/bin/poetry completions bash`
    (bash_completion/"poetry").write output

    output = `#{libexec}/bin/poetry completions zsh`
    (zsh_completion/"_poetry").write output

    output = `#{libexec}/bin/poetry completions fish`
    (fish_completion/"poetry.fish").write output
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
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_match "Commands", shell_output("#{bin}/poetry")
    system "#{bin}/poetry", "install", "requests"
    system "#{bin}/poetry", "install", "boto3"
    assert_predicate testpath/"pyproject.toml", :exist?
    assert_predicate testpath/"poetry.lock", :exist?
    assert_match "requests", (testpath/"pyproject.toml").read
    assert_match "boto3", (testpath/"pyproject.toml").read
  end
end
