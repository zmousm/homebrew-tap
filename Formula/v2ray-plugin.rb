class V2rayPlugin < Formula
  desc "SIP003 plugin based on v2ray"
  homepage "https://github.com/shadowsocks/v2ray-plugin"
  url "https://github.com/shadowsocks/v2ray-plugin/archive/refs/tags/v1.3.2.tar.gz"
  sha256 "0ffb0a938bae58ea40a024cb04418c7fecb74f7d807de27ae0589c42307802a4"
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
