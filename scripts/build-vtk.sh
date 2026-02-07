#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VTK_SRC="$ROOT/extern/vtk"
CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

PLATFORM="linux-x64"
INSTALL_PREFIX="$ROOT/install/$PLATFORM/$CFG/vtk"
BUILD_DIR="$ROOT/build/vtk/linux/$CFG"

[ -f "$VTK_SRC/CMakeLists.txt" ] || { echo "[ERR] VTK source not found: $VTK_SRC" >&2; exit 1; }

sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET" "manifests/vtk"

cmake -S "$VTK_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$CFG" \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/extern/vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT/manifests/vtk" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DBUILD_SHARED_LIBS=ON \
  -DVTK_BUILD_TESTING=OFF \
  -DVTK_BUILD_EXAMPLES=OFF \
  -DVTK_WRAP_PYTHON=OFF \
  -DVTK_ENABLE_WRAPPING=OFF \
  -DVTK_GROUP_ENABLE_Qt=NO

cmake --build "$BUILD_DIR" --target install
echo "[OK] VTK installed: $INSTALL_PREFIX"
