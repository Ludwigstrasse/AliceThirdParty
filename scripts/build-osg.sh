#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OSG_SRC="$ROOT/extern/osg"
CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

PLATFORM="linux-x64"
INSTALL_PREFIX="$ROOT/install/$PLATFORM/$CFG/osg"
BUILD_DIR="$ROOT/build/osg/linux/$CFG"

[ -f "$OSG_SRC/CMakeLists.txt" ] || { echo "[ERR] OSG source not found: $OSG_SRC" >&2; exit 1; }

sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET" "manifests/osg"

cmake -S "$OSG_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$CFG" \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/extern/vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT/manifests/osg" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DBUILD_SHARED_LIBS=ON \
  -DOSG_BUILD_EXAMPLES=OFF \
  -DOSG_BUILD_APPLICATIONS=OFF \
  -DOSG_BUILD_TESTS=OFF

cmake --build "$BUILD_DIR" --target install
echo "[OK] OSG installed: $INSTALL_PREFIX"
