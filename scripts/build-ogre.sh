#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OGRE_SRC="$ROOT/extern/ogre"
CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

PLATFORM="linux-x64"
INSTALL_PREFIX="$ROOT/install/$PLATFORM/$CFG/ogre"
BUILD_DIR="$ROOT/build/ogre/linux/$CFG"

[ -f "$OGRE_SRC/CMakeLists.txt" ] || { echo "[ERR] OGRE source not found: $OGRE_SRC" >&2; exit 1; }

sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET" "manifests/ogre"

cmake -S "$OGRE_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$CFG" \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/extern/vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT/manifests/ogre" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DBUILD_SHARED_LIBS=ON \
  -DOGRE_BUILD_SAMPLES=OFF \
  -DOGRE_BUILD_TESTS=OFF \
  -DOGRE_BUILD_TOOLS=OFF \
  -DOGRE_BUILD_COMPONENT_BITES=OFF \
  -DOGRE_BUILD_COMPONENT_OVERLAY=OFF \
  -DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON \
  -DOGRE_BUILD_RENDERSYSTEM_VULKAN=OFF \
  -DOGRE_BUILD_DEPENDENCIES=OFF \
  -DOGRE_CONFIG_ENABLE_FREEIMAGE=OFF

cmake --build "$BUILD_DIR" --target install
echo "[OK] OGRE installed: $INSTALL_PREFIX"
