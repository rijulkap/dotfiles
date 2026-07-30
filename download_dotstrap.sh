#!/usr/bin/env bash

set -euo pipefail

# readonly VERSION="v0.1.8"
readonly REPOSITORY="rijulkap/dotstrap"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s):$(uname -m)" in
  Linux:x86_64 | Linux:amd64)
    asset="dotstrap-linux-x64"
    ;;
  Linux:aarch64 | Linux:arm64)
    asset="dotstrap-linux-aarch64"
    ;;
  Darwin:x86_64 | Darwin:amd64)
    asset="dotstrap-macos-x64"
    ;;
  Darwin:arm64 | Darwin:aarch64)
    asset="dotstrap-macos-aarch64"
    ;;
  *)
    printf 'error: unsupported platform: %s %s\n' "$(uname -s)" "$(uname -m)" >&2
    exit 1
    ;;
esac

url="https://github.com/${REPOSITORY}/releases/lastest/download/${asset}"
destination="${SCRIPT_DIR}/dotstrap"
temporary="${SCRIPT_DIR}/.dotstrap.download.$$"

cleanup() {
  rm -f -- "$temporary"
}
trap cleanup EXIT

printf 'Downloading %s\n' "$url"
curl --fail --location --show-error --silent \
  --output "$temporary" \
  "$url"
chmod +x "$temporary"
mv -f -- "$temporary" "$destination"

printf 'Installed dotstrap at %s\n' "$destination"
