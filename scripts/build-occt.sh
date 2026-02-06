#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OCCT_SRC="$ROOT/extern/occt"
VCPKG="$ROOT/extern/vcpkg"

CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

if [ "$CFG" = "Debug" ]; then
  INSTALL_PREFIX="$ROOT/install/linux-x64/Debug"
  BUILD_TYPE="Debug"
else
  INSTALL_PREFIX="$ROOT/install/linux-x64/Release"
  BUILD_TYPE="Release"
fi

BUILD_DIR="$ROOT/build/occt/linux/$CFG"

sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET"

cmake -S "$OCCT_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DBUILD_LIBRARY_TYPE=Shared \
  -DBUILD_TESTING=OFF \
  -DUSE_OPENGL=ON \
  -DUSE_TBB=ON \
  -DUSE_FREETYPE=ON

cmake --build "$BUILD_DIR" --target install

echo "[OK] OCCT built and installed to: $INSTALL_PREFIX"
