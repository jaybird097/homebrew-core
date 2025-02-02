require "language/node"

class Cdk8s < Formula
  desc "Define k8s native apps and abstractions using object-oriented programming"
  homepage "https://cdk8s.io/"
  url "https://registry.npmjs.org/cdk8s-cli/-/cdk8s-cli-2.0.120.tgz"
  sha256 "acc31408320b93e1d557ebb1a7375928a4df3efdbd43b9a382e010be70767255"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "e945676ebeb62df290b48aee647acde34a8996f0d4c6f1729e6bab4739e7ae50"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "Cannot initialize a project in a non-empty directory",
      shell_output("#{bin}/cdk8s init python-app 2>&1", 1)
  end
end
