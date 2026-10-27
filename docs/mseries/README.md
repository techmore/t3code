# elementary OS on Apple Silicon (M-series, aarch64)

This fork builds and runs on aarch64 Linux with 16 KiB pages (Asahi). Changes against upstream are kept
small so `git merge upstream/main` stays cheap:

| Change                                                                                                                                                                          | Where                                |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| Cargo helper builds (resource monitor, snap-shot) pin `CARGO_TARGET_DIR`, so a global `build.target-dir` in `~/.cargo/config.toml` no longer hides the binary from the packager | `scripts/build-desktop-artifact.ts`  |
| `dist:desktop:linux:arm64`                                                                                                                                                      | `package.json`                       |
| Pinned Node and pnpm without touching the system Node                                                                                                                           | `scripts/mseries/bootstrap-arm64.sh` |
| `zod` declared in the server (peer dependency of `@cursor/sdk`; without it the packaged backend exits on `Cannot find module 'zod/v4'`)                                         | `apps/server/package.json`           |

## Build

```sh
eval "$(scripts/mseries/bootstrap-arm64.sh)"   # prints the PATH export for the pinned toolchain
pnpm install --frozen-lockfile
pnpm run dist:desktop:linux:arm64              # needs imagemagick; writes release/*.AppImage and *.deb
```

Linux arm64 on a 16 KiB-page kernel also needs upstream's SEA workaround (#25825, in
`scripts/lib/linux-arm64-sea.ts`); it is marked TEMPORARY upstream until Node ships a fix
(nodejs/node#67048).

## Native client

The Pantheon (GTK4/Granite) client is `claude-pantheon-rs` in the ElementaryOS_MSeries repo. It speaks this
server's Effect-RPC protocol; `scripts/refresh-contracts.sh` there reads this checkout, so merge upstream
here before refreshing.

## Run a test instance without touching the real one

```sh
node apps/server/dist/bin.mjs serve --port 3774 --base-dir /tmp/t3-test --no-browser
node apps/server/dist/bin.mjs auth pairing create --base-dir /tmp/t3-test   # one-time token
```
