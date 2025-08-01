  # HOMEBREW_NO_INSTALL_FROM_API=1 brew audit --new envop
  # HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose --debug envop
  # HOMEBREW_NO_INSTALL_FROM_API=1 brew test envop

# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Envop < Formula
  desc ""
  homepage "https://github.com/yakmoose/envop"
  url "https://github.com/yakmoose/envop/archive/refs/tags/v0.2.5.tar.gz"
  sha256 "d740cf13d49913216b795c949a626cb05cefdb9a65f1dc3c1691d0a162f0d22f"
  license "MIT"

  depends_on "go" => :build

  head do
    url "https://github.com/yakmoose/envop.git", branch: "main"
    depends_on "go" => :build
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test envop`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
