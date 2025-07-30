# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Libngtcp2 < Formula
  desc "ngtcp2 project is an effort to implement IETF QUIC protocol"
  homepage "https://nghttp2.org/ngtcp2/"
  url "https://github.com/ngtcp2/ngtcp2/releases/download/v1.14.0/ngtcp2-1.14.0.tar.gz"
  sha256 "25272473f12eaf7a04f8f437edd892753e5e772f490f469609609b75693d4910"
  license "MIT"


  head do
    url "https://github.com/ngtcp2/ngtcp2.git", branch: "main"
    depends_on "pkgconf" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "libnghttp3"
  depends_on "openssl@3"

  depends_on "pkgconf" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    system "autoreconf", "-fi"
    system "./configure", "--disable-silent-rules", "--enable-lib-only=1", *std_configure_args
    system "make", "install" 
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test libngtcp2`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
