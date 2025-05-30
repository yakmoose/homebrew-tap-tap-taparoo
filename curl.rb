class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  # Don't forget to update both instances of the version in the GitHub mirror URL.
  # `url` goes below this comment when the `stable` block is removed.
  url "https://curl.se/download/curl-8.14.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_14_0/curl-8.14.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.14.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-8.14.0.tar.bz2"
  sha256 "efa1403c5ac4490c8d50fc0cabe97710abb1bf2a456e375a56d960b20a1cba80"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  depends_on "pkgconf" => [:build, :test]
  depends_on "brotli"
  depends_on "libnghttp2"
  depends_on "libnghttp3"
  depends_on "libngtcp2"
  depends_on "libssh2"
  depends_on "openssl@3"
  depends_on "rtmpdump"
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "openldap"
  
  # why system zlib?
  uses_from_macos "zlib", since: :sierra

  on_system :linux, macos: :monterey_or_older do
    depends_on "libidn2"
  end

  def install
    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(/github\.com/).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
           "Please make sure the URL is correct."
    end

    system "autoreconf", "--force", "--install", "--verbose" if build.head?

    args = %W[
      --disable-silent-rules
      --with-nghttp3=#{Formula["libnghttp3"].opt_prefix}
      --with-ngtcp2=#{Formula["libngtcp2"].opt_prefix}      
      --with-ssl=#{Formula["openssl@3"].opt_prefix}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-librtmp
      --with-libssh2
      --with-zlib
      --with-zstd
      --with-brotli
      --with-libpsl
      --with-apple-idn
      --without-libidn2
      --enable-alt-svc
      --enable-doh
      --with-zsh-functions-dir=#{zsh_completion}
      --with-fish-functions-dir=#{fish_completion}      
    ]

    args << if OS.mac?
      "--with-gssapi"
    else
      "--with-gssapi=#{Formula["krb5"].opt_prefix}"
    end

    # args += if OS.mac? && MacOS.version >= :ventura
    #   %w[
    #     --with-apple-idn
    #     --without-libidn2
    #   ]
    # else
    #   %w[
    #     --without-apple-idn
    #     --with-libidn2
    #   ]
    # end

    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = testpath/"test.tar.gz"
    system bin/"curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # Check dependencies linked correctly
    curl_features = shell_output("#{bin}/curl-config --features").split("\n")
    %w[brotli GSS-API HTTP2 HTTP3 IDN libz SSL zstd alt-svc].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS RTMP SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"

    with_env(PKG_CONFIG_PATH: lib/"pkgconfig") do
      system "pkgconf", "--cflags", "libcurl"
    end
  end
end
