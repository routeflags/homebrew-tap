class Kaseifu < Formula
  desc "Semantic file organizer for macOS"
  homepage "https://github.com/smapira/kaseifu"
  url "https://github.com/smapira/kaseifu/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "e8e5c9046c61038440e5b9dedfc6f970a986b961d27c9b690149f6d7df3cdfb4"
  license "MIT"

  depends_on "rust" => :build

  # `@Generable` (Foundation Models) is expanded by a macro plugin that only
  # Xcode.app ships: a Command Line Tools-only machine fails the build.
  depends_on xcode: ["26.0", :build]

  # No `livecheck` block: the tag archive URL is followed by livecheck's
  # default Git strategy, which resolves the `vX.Y.Z` tags directly.

  def install
    # `std_cargo_args` builds against Cargo.lock and installs both binaries
    # declared in Cargo.toml: `kaseifu` and `kaseifu-bench`.
    system "cargo", "install", *std_cargo_args
  end

  test do
    ENV["KASEIFU_KEY_SOURCE"] = "env"
    ENV["KASEIFU_NO_COMPLETION_UPDATE"] = "1"

    assert_match version.to_s, shell_output("#{bin}/kaseifu --version")
    assert_match version.to_s, shell_output("#{bin}/kaseifu-bench --version")

    # A bare invocation only prints the guidance: exit 0, no side effects.
    guidance = shell_output("#{bin}/kaseifu")
    assert_match "kaseifu organize <file>", guidance
    assert_predicate guidance, :ascii_only?

    assert_predicate shell_output("#{bin}/kaseifu label --help"), :ascii_only?

    # `kaseifu label --format json` is deliberately not exercised here: that
    # path opens the state database, and this test must stay side-effect free.
  end
end
