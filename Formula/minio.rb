class Minio < Formula
  desc "High Performance, Kubernetes Native Object Storage"
  homepage "https://min.io"
  url "https://github.com/minio/minio.git",
      tag:      "RELEASE.2022-09-22T18-57-27Z",
      revision: "20c89ebbb30f44bbd0eba4e462846a89ab3a56fa"
  version "20220922185727"
  license "AGPL-3.0-or-later"
  head "https://github.com/minio/minio.git", branch: "master"

  livecheck do
    url :stable
    regex(%r{href=.*?/tag/(?:RELEASE[._-]?)?([\d\-TZ]+)["' >]}i)
    strategy :github_latest do |page, regex|
      page.scan(regex).map { |match| match&.first&.gsub(/\D/, "") }
    end
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1efdbd7b5589e4fd07a5a19ec883819e67d0eed39646b09f87d016bef4b89eea"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "40b973c074711acb1b5940c1b8dd8b2b8fb16d603b39b56b0561d313f38bfd68"
    sha256 cellar: :any_skip_relocation, monterey:       "ed9b7bacd25dc6dc24df8771a6006b94e937d3efc1cd3ba770196222416b2f58"
    sha256 cellar: :any_skip_relocation, big_sur:        "ef1abbd0d0f396a0445cc55dc43efd15fb167c819cc46ef4c57db53586737948"
    sha256 cellar: :any_skip_relocation, catalina:       "1d3cf3277987b2eb71c54f5a807de6809de24b80a84b10d77a0a151d8c5790e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "758968d48d4f858372c0e53b0fa3ff36975d39c37c2b55e83338bf368022e56b"
  end

  depends_on "go" => :build

  def install
    if build.head?
      system "go", "build", *std_go_args
    else
      release = `git tag --points-at HEAD`.chomp
      version = release.gsub(/RELEASE\./, "").chomp.gsub(/T(\d+)-(\d+)-(\d+)Z/, 'T\1:\2:\3Z')

      ldflags = %W[
        -s -w
        -X github.com/minio/minio/cmd.Version=#{version}
        -X github.com/minio/minio/cmd.ReleaseTag=#{release}
        -X github.com/minio/minio/cmd.CommitID=#{Utils.git_head}
      ]

      system "go", "build", *std_go_args(ldflags: ldflags)
    end
  end

  def post_install
    (var/"minio").mkpath
    (etc/"minio").mkpath
  end

  service do
    run [opt_bin/"minio", "server", "--config-dir=#{etc}/minio", "--address=:9000", var/"minio"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/minio.log"
    error_log_path var/"log/minio.log"
  end

  test do
    assert_match "minio server - start object storage server",
      shell_output("#{bin}/minio server --help 2>&1")

    assert_match "minio gateway - start object storage gateway",
      shell_output("#{bin}/minio gateway 2>&1")
    assert_match "ERROR Unable to validate credentials",
      shell_output("#{bin}/minio gateway s3 2>&1", 1)
  end
end
