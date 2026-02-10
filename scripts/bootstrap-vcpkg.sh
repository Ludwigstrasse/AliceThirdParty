#!/usr/bin/env sh
set -eu

# Usage: bootstrap-vcpkg.sh <triplet> <manifest_dir>
TRIPLET="${1:-x64-linux}"
MANIFEST="${2:-}"
if [ -z "$MANIFEST" ]; then
  echo "[ERR] manifest_dir is required. e.g. manifests/occt" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VCPKG_DIR="$ROOT/extern/vcpkg"
VCPKG_BIN="$VCPKG_DIR/vcpkg"

# Avoid env confusion
unset VCPKG_ROOT || true

# Bootstrap vcpkg if needed
if [ ! -x "$VCPKG_BIN" ]; then
  echo "[VCPKG] bootstrapping..."
  if [ ! -f "$VCPKG_DIR/bootstrap-vcpkg.sh" ]; then
    echo "[ERR] vcpkg submodule not initialized: $VCPKG_DIR" >&2
    echo "      Run: git submodule update --init --recursive" >&2
    exit 1
  fi
  (cd "$VCPKG_DIR" && ./bootstrap-vcpkg.sh -disableMetrics)
fi

echo "[VCPKG] triplet=$TRIPLET"
echo "[VCPKG] manifest=$MANIFEST"

"$VCPKG_BIN" install --triplet "$TRIPLET" --x-manifest-root="$ROOT/$MANIFEST"
