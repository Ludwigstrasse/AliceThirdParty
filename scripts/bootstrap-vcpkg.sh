#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VCPKG="$ROOT/extern/vcpkg"
TRIPLET="${1:-x64-linux}"

if [ ! -f "$VCPKG/bootstrap-vcpkg.sh" ]; then
  echo "[ERR] vcpkg submodule not found: $VCPKG" >&2
  exit 1
fi

(
  cd "$VCPKG"
  ./bootstrap-vcpkg.sh -disableMetrics || true
)

# Install manifest dependencies into $ROOT/vcpkg_installed
"$VCPKG/vcpkg" install --triplet "$TRIPLET" --x-manifest-root="$ROOT"

echo "[OK] vcpkg install done. triplet=$TRIPLET"
