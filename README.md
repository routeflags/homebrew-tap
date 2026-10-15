# routeflags/homebrew-tap

Homebrew formulae for [kaseifu](https://github.com/smapira/kaseifu) — a semantic
file organizer for macOS. The formula is maintained here by the kaseifu author;
the upstream source lives in `smapira/kaseifu`.

## Install

```bash
brew tap routeflags/tap
brew trust --formula routeflags/tap/kaseifu
brew install kaseifu
kaseifu --version
```

`brew trust` is what lets Homebrew load a formula from a non-official tap
(required since Homebrew 6.0). Trusting the single formula keeps the trust
narrower than trusting the whole tap. The one-step equivalent, which needs no
trust line because the name is fully qualified, is:

```bash
brew install routeflags/tap/kaseifu
```

Both binaries of the package are installed: `kaseifu` and `kaseifu-bench`.

## Requirements

- **Xcode 26 or later.** The build compiles the Swift Foundation Models bridge,
  and the `@Generable` macro plugin that bridge needs ships inside Xcode.app. A
  machine with only the Command Line Tools fails the build.
- **A source build.** No bottles are published yet, so the first install
  compiles from source. Homebrew installs Rust as a build dependency, along with
  Rust's own build dependencies (`llvm` among them): expect a large download and
  several minutes of building.
- **Runtime.** The `kaseifu` binary runs on macOS 12 or later. The AI rename
  feature needs macOS 26 with Apple Intelligence; on older systems the CLI still
  works and reports that feature as unavailable.

## Updating this tap

1. Find the newest release tag:

   ```bash
   git ls-remote --tags --refs https://github.com/smapira/kaseifu \
     | sed 's#.*refs/tags/##' | sort -V | tail -1
   ```

2. Measure the source tarball (never guess the checksum):

   ```bash
   curl -sSL -o kaseifu.tar.gz \
     https://github.com/smapira/kaseifu/archive/refs/tags/vX.Y.Z.tar.gz
   shasum -a 256 kaseifu.tar.gz
   ```

3. Update `url` and `sha256` in `Formula/kaseifu.rb`.

4. Verify against the local checkout. Homebrew refuses formula paths, so the tap
   has to be visible to brew first (`brew tap routeflags/tap` after the push, or
   a symlink to this checkout at
   `"$(brew --repository)/Library/Taps/routeflags/homebrew-tap"` before it):

   ```bash
   brew audit --strict --new routeflags/tap/kaseifu
   brew install --build-from-source routeflags/tap/kaseifu
   brew test routeflags/tap/kaseifu
   brew livecheck routeflags/tap/kaseifu
   ```

5. Commit and push to `main` (fast-forward only; no history rewrites).

### Maintenance notes

- There is no `livecheck` block on purpose. The `url` is a GitHub tag archive, and
  livecheck's default Git strategy already resolves the `vX.Y.Z` tags.
- `depends_on xcode: ["26.0", :build]` is intentional: the Command Line Tools
  ship the macOS 26 SDK but not the macro plugin, so a CLT-only machine fails
  inside the Swift build.
- Bottles are not published yet, so every install is a source build. That is the
  Phase 2 item for this tap.
