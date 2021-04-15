class Smlnj < Formula
  desc "Standard ML of New Jersey"
  homepage "https://www.smlnj.org/"
  url "http://smlnj.cs.uchicago.edu/dist/working/110.99/config.tgz"
  sha256 "c583510b02eb8d5c720d7778527cad5b102c0ef7bb41a6af6eeec2aaa4efcb84"

  resource "cm" do
    url "https://www.smlnj.org/dist/working/110.99/cm.tgz"
    sha256 "9e86660796ca5c55672752bb76ee14c3e8b24f1674bff4ec929e5e02e0b17ac2"
  end

  resource "compiler" do
    url "https://www.smlnj.org/dist/working/110.99/compiler.tgz"
    sha256 "5d9caece91e0f9b42b9903251a53bfc941012e8521ef095006764074a056a4e8"
  end

  resource "runtime" do
    url "https://www.smlnj.org/dist/working/110.99/runtime.tgz"
    sha256 "9826e3ca9ebe94e4b59005a256dd7824d3b1e58298f74dfa85f3c10066ca14b5"
  end

  resource "system" do
    url "https://www.smlnj.org/dist/working/110.99/system.tgz"
    sha256 "25e42022aa82b8b2dad00024e4dd6e0cdc7a762c216fcab4f486480735011f8d"
  end

  resource "bootstrap" do
    url "https://www.smlnj.org/dist/working/110.99/boot.amd64-unix.tgz"
    sha256 "526e00f128b2865efa7b4b9ab638e7137eb60f7c7bb664c08953f035871193fc"
  end

  resource "mlrisc" do
    url "https://www.smlnj.org/dist/working/110.99/MLRISC.tgz"
    sha256 "79eaf05a0c9b9f1732ae6fcdb5182e6783b399f9500c8a31d25460d28ebb1e3c"
  end

  resource "lib" do
    url "https://www.smlnj.org/dist/working/110.99/smlnj-lib.tgz"
    sha256 "989d9c03c228fa7776a14a0ae39ab67cbd961d02eb5766159c2d37127edab736"
  end

  resource "ckit" do
    url "https://www.smlnj.org/dist/working/110.99/ckit.tgz"
    sha256 "794609cc8e4a149156d5442acfb21f7f0808cd40ef0590de9bff38e247cb5a7e"
  end

  resource "nlffi" do
    url "https://www.smlnj.org/dist/working/110.99/nlffi.tgz"
    sha256 "172dcfda23b497f5b22336be3f346728341da96c0339fba9828fb1a50a69cd17"
  end

  resource "cml" do
    url "https://www.smlnj.org/dist/working/110.99/cml.tgz"
    sha256 "ebcefb032ab939bdb7a921ba27b5fb29a22893986f0e6bbd516ef82b766d2b2e"
  end

  resource "exene" do
    url "https://www.smlnj.org/dist/working/110.99/eXene.tgz"
    sha256 "0918107d6a3afd57e75efccceafab1c692f80e0481bdd189571babbef4bd8942"
  end

  resource "ml-lpt" do
    url "https://www.smlnj.org/dist/working/110.99/ml-lpt.tgz"
    sha256 "dcba38807c7514710b0b46a946dc6181279685ffedd7d1bef95ca0165a90948f"
  end

  resource "ml-lex" do
    url "https://www.smlnj.org/dist/working/110.99/ml-lex.tgz"
    sha256 "d838bd69bc83a24bd8fee869eb133990cb98c6672290e19bc504fa32901b3268"
  end

  resource "ml-yacc" do
    url "https://www.smlnj.org/dist/working/110.99/ml-yacc.tgz"
    sha256 "cbd38c12172fb5ac7ec97d17044adcaa24d39d5abf4fb7f641d24fe082b8f286"
  end

  resource "ml-burg" do
    url "https://www.smlnj.org/dist/working/110.99/ml-burg.tgz"
    sha256 "58053b8e8fef8d2fa0cc48f9c3be501e75cf227699784b1467902024d58ae0fb"
  end

  resource "pgraph" do
    url "https://www.smlnj.org/dist/working/110.99/pgraph.tgz"
    sha256 "78a07256bcb7f6cafa05b9af7c2091783d878c14a8fcf7f72a5aba9ee57b32dc"
  end

  resource "trace-debug-profile" do
    url "https://www.smlnj.org/dist/working/110.99/trace-debug-profile.tgz"
    sha256 "7015a035e8d6c3aec6333295605d7511ff8307ecea0fa6171995cda3e831f915"
  end

  resource "heap2asm" do
    url "https://www.smlnj.org/dist/working/110.99/heap2asm.tgz"
    sha256 "3e725747b796c1906c8d4439095bde9d1181d9df80c296163207b63ca8b64730"
  end

  resource "c" do
    url "https://www.smlnj.org/dist/working/110.99/smlnj-c.tgz"
    sha256 "ba8e438ffb2211a5f66531918b5767fe11512e72ab3d2461c5c78b81f6ac96a4"
  end

  def install
    ENV.deparallelize

    # Build in place
    root = prefix/"SMLNJ_HOME"
    root.mkpath
    cp_r buildpath, root/"config"

    # Rewrite targets list (default would be too minimalistic)
    rm root/"config/targets"
    (root/"config/targets").write targets

    # Download and extract all the sources for the base system
    %w[cm compiler runtime system].each do |name|
      resource(name).stage { cp_r pwd, root/"base" }
    end

    # Download the remaining packages that go directly into the root
    %w[
      bootstrap mlrisc lib ckit nlffi
      cml exene ml-lpt ml-lex ml-yacc ml-burg pgraph
      trace-debug-profile heap2asm c
    ].each do |name|
      resource(name).stage { cp_r pwd, root }
    end

    # inreplace root/"base/runtime/config/gen-posix-names.sh" do |s|
    #  s.gsub! "PATH=/bin:/usr/bin", "# do not hardcode the path"
    # end

    # inreplace root/"config/_arch-n-opsys", "16*) OPSYS=linux", "1*) OPSYS=linux"
    # https://github.com/macports/macports-ports/blob/master/lang/smlnj/Portfile

    cd root do
      system "config/install.sh", "-default", "64"
    end

    %w[
      sml heap2asm heap2exec ml-antlr
      ml-build ml-burg ml-lex ml-makedepend
      ml-nlffigen ml-ulex ml-yacc
    ].each { |e| bin.install_symlink root/"bin/#{e}" }
  end

  def targets
    <<~EOS
      request ml-ulex
      request ml-ulex-mllex-tool
      request ml-lex
      request ml-lex-lex-ext
      request ml-yacc
      request ml-yacc-grm-ext
      request ml-antlr
      request ml-lpt-lib
      request ml-burg
      request smlnj-lib
      request tdp-util
      request cml
      request cml-lib
      request mlrisc
      request ml-nlffigen
      request ml-nlffi-lib
      request mlrisc-tools
      request eXene
      request pgraph-util
      request ckit
      request heap2asm
    EOS
  end

  test do
    system bin/"ml-nlffigen"
    assert_predicate testpath/"NLFFI-Generated/nlffi-generated.cm", :exist?
  end
end
