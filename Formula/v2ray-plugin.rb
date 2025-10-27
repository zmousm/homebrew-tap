class V2rayPlugin < Formula
  desc "SIP003 plugin based on v2ray"
  homepage "https://github.com/shadowsocks/v2ray-plugin"
  # pseudo-version, latest commits fix build issues
  url "https://github.com/shadowsocks/v2ray-plugin/archive/e9af1cdd2549d528deb20a4ab8d61c5fbe51f306.tar.gz"
  version "1.3.2.20241102"
  sha256 "c7470b688492028bda5548607061acbbfc3067960266235eaf837240f5f89718"
  license "MIT"

  head "https://github.com/shadowsocks/v2ray-plugin.git", branch: "master"

  depends_on "go" => :build

  def install
    # Mirror upstream: CGO off; stamp VERSION; strip symbols.
    ENV["CGO_ENABLED"] = "0"

    version_str = if build.head?
      # mimic upstream: `git describe --tags` when building from HEAD
      Utils.git_short_head ? `git -C #{cached_download} describe --tags 2>/dev/null`.chomp : version
    else
      version
    end
    ldflags = %W[
      -s -w -buildid=
      -X main.VERSION=#{version_str}
    ]

    system "go", "build", *std_go_args(ldflags: ldflags.join(" "))
  end

  test do
    help = shell_output("#{bin}/v2ray-plugin -h 2>&1")
    assert_match "v2ray-plugin", help
    # server = fork do
    #   exec bin/"v2ray-plugin", "-localPort", "54000", "-remoteAddr", "github.com", "-remotePort", "80", "-server"
    # end
    # client = fork do
    #   exec bin/"v2ray-plugin", "-localPort", "54001", "-remotePort", "54000"
    # end
    # sleep 2
    # begin
    #   system "curl", "localhost:54001"
    # ensure
    #   Process.kill 9, server
    #   Process.wait server
    #   Process.kill 9, client
    #   Process.wait client
    # end
  end
end
