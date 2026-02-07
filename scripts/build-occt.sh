#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OCCT_SRC="$ROOT/extern/occt"
CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

PLATFORM="linux-x64"
INSTALL_PREFIX="$ROOT/install/$PLATFORM/$CFG/occt"
BUILD_DIR="$ROOT/build/occt/linux/$CFG"

[ -f "$OCCT_SRC/CMakeLists.txt" ] || { echo "[ERR] OCCT source not found: $OCCT_SRC" >&2; exit 1; }

sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET" "manifests/occt"

cmake -S "$OCCT_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$CFG" \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/extern/vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT/manifests/occt" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DBUILD_LIBRARY_TYPE=Shared \
  -DBUILD_TESTING=OFF \
  -DUSE_OPENGL=ON \
  -DUSE_TBB=ON \
  -DUSE_FREETYPE=ON

cmake --build "$BUILD_DIR" --target install
echo "[OK] OCCT installed: $INSTALL_PREFIX"
