#!/usr/bin/env bash
# Prepare an aarch64 Linux host (elementary OS M-series) to build this repo.
# Installs the pinned Node and pnpm under ~/.local without touching system Node.
set -euo pipefail
cd "$(dirname "$0")/../.."
[ "$(uname -m)" = aarch64 ] || { echo "aarch64 only" >&2; exit 1; }
NODE_VERSION=$(node -p 'require("./package.json").engines.node' 2>/dev/null || sed -n 's/.*"node": "\([0-9.]*\)".*/\1/p' package.json | head -1)
PNPM_VERSION=$(sed -n 's/.*"packageManager": "pnpm@\(.*\)".*/\1/p' package.json)
PREFIX=${MSERIES_TOOLCHAIN:-$HOME/.local/t3code-toolchain}
mkdir -p "$PREFIX"
if [ ! -x "$PREFIX/node-v$NODE_VERSION-linux-arm64/bin/node" ]; then
  curl -fsSL "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-arm64.tar.xz" | tar -xJ -C "$PREFIX"
fi
export PATH="$PREFIX/node-v$NODE_VERSION-linux-arm64/bin:$PATH"
npm i -g "pnpm@$PNPM_VERSION" --prefix "$PREFIX/pnpm" >/dev/null
echo "export PATH=$PREFIX/node-v$NODE_VERSION-linux-arm64/bin:$PREFIX/pnpm/bin:$PWD/node_modules/.bin:\$PATH"
