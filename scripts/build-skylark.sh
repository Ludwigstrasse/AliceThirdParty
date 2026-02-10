#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKY_SRC="$ROOT/extern/skylark"
CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

PLATFORM="linux-x64"
INSTALL_PREFIX="$ROOT/install/$PLATFORM/$CFG/skylark"
BUILD_DIR="$ROOT/build/skylark/linux/$CFG"

[ -f "$SKY_SRC/CMakeLists.txt" ] || { echo "[ERR] Skylark source not found: $SKY_SRC" >&2; exit 1; }

sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET" "manifests/skylark"

cmake -S "$SKY_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$CFG" \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/extern/vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT/manifests/skylark" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

cmake --build "$BUILD_DIR" --target install
echo "[OK] Skylark installed: $INSTALL_PREFIX"
