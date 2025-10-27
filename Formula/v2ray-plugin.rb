class V2rayPlugin < Formula
  desc "SIP003 plugin based on v2ray"
  homepage "https://github.com/shadowsocks/v2ray-plugin"
  # pseudo-version, latest commits fix build issues
  url "https://github.com/shadowsocks/v2ray-plugin/archive/e9af1cdd2549d528deb20a4ab8d61c5fbe51f306.tar.gz"
  version "1.3.2.20241102"
  sha256 "c7470b688492028bda5548607061acbbfc3067960266235eaf837240f5f89718"
  license "MIT"

  head "https://github.com/shadowsocks/v2ray-plugin.git", branch: "master"

  bottle do
    root_url "https://github.com/zmousm/homebrew-tap/releases/download/v2ray-plugin-1.3.2.20241102"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b249bb02a9d67a9e48444bb9632ebff4c727cdcfa10e50e5bd96043491dca67e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "022e5c2d3f6ce86a597a27af26a59e3234d52b24a2ec9461d2e9d065b7fb15e4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "11fb175429d477024d7e70f651bcf1bcc3bf626eb2a66f43583fec0371036086"
  end

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
  end
end
