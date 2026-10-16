class Kaseifu < Formula
  desc "Semantic file organization for macOS"
  homepage "https://github.com/smapira/kaseifu"
  url "https://github.com/smapira/kaseifu/archive/refs/tags/v0.12.3.tar.gz"
  sha256 "11b397b99217ed11d29ff4f89c9a82f063cfe0e587e24978ea5e276f9e54c5e3"
  license "MIT"

  depends_on "rust" => :build

  # `@Generable` (Foundation Models) is expanded by a macro plugin that only
  # Xcode.app ships: a Command Line Tools-only machine fails the build. The
  # requirement compares the Xcode.app version, not the SDK version.
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

    assert_match "kaseifu #{version}", shell_output("#{bin}/kaseifu --version")
    assert_match "kaseifu-bench #{version}", shell_output("#{bin}/kaseifu-bench --version")

    # `brew test` sets HOME to a staging directory, so the state database the
    # `label` guidance opens is created there and never in the real HOME.
    assert_match "usage:", shell_output("#{bin}/kaseifu label")

    label_help = shell_output("#{bin}/kaseifu label --help")
    assert_match "Usage: kaseifu label", label_help
    assert_predicate label_help, :ascii_only?
  end
end
