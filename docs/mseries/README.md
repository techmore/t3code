# elementary OS on Apple Silicon (M-series, aarch64)

Builds and runs on aarch64 Linux with 16 KiB pages (Asahi). The fork stays close to upstream so
`git merge upstream/main` stays cheap.

## What differs from upstream

| Change                                                                                                                                                       | Why                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `resolveCargoTargetDirectory` in `scripts/build-desktop-artifact.ts` asks `cargo metadata` where the Rust helpers (resource monitor, snap-shot) were written | The packager assumed `native/<crate>/target`. With `build.target-dir` set in a cargo config (or `CARGO_TARGET_DIR`), cargo writes elsewhere and packaging failed with `ResourceMonitorBuildOutputMissingError`. Not arm64-specific; in a default setup it resolves to the same path as before. |
| `dist:desktop:linux:arm64` in `package.json`                                                                                                                 | Convenience; `dist:desktop:linux` is hardcoded to x64.                                                                                                                                                                                                                                         |
| `scripts/mseries/bootstrap-arm64.sh`                                                                                                                         | Installs the pinned Node and pnpm under `~/.local` without touching the system Node.                                                                                                                                                                                                           |

## Things that were suspected but are not fork changes

- **zod**: the packaged server failed on `Cannot find module 'zod/v4'` (peer dependency of `@cursor/sdk`).
  Fixed upstream in #25841 (`zod` declared in `apps/server`); the fork takes upstream's change.
- **16 KiB pages**: upstream's `scripts/lib/linux-arm64-sea.ts` (#25825) works around a Node `--build-sea` bug
  that breaks the CLI single-executable (the background service runtime) on 16 KiB/64 KiB-page kernels. It does
  not affect the Electron/AppImage path. Checked on this machine: `node apps/server/scripts/cli.ts build-exe`
  produces a `t3` that runs (`t3 --version`).
- What blocked an out-of-the-box build here was the toolchain: the repo pins Node 26.12.1 and pnpm 12.14.0
  exactly, and the system Node 22 fails with `ERR_UNKNOWN_FILE_EXTENSION .ts`.

## Build

```sh
eval "$(scripts/mseries/bootstrap-arm64.sh)"   # prints the PATH export for the pinned toolchain
pnpm install --frozen-lockfile
pnpm run dist:desktop:linux:arm64              # needs imagemagick; writes release/*.AppImage and *.deb
```

## Native client

The Pantheon (GTK4/Granite) client is `claude-pantheon-rs` in techmore/mseries-sdk-apps. It speaks this
server's Effect-RPC protocol; its `scripts/refresh-contracts.sh` reads this checkout, so merge upstream
here before refreshing.

## Run a test instance without touching the real one

```sh
node apps/server/dist/bin.mjs serve --port 3774 --base-dir /tmp/t3-test --no-browser
node apps/server/dist/bin.mjs auth pairing create --base-dir /tmp/t3-test   # one-time token
```
