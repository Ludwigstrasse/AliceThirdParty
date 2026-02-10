#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OCCT_SRC="$ROOT/extern/OCCT"
CFG="${1:-Release}"
TRIPLET="${2:-x64-linux}"

PLATFORM="linux-x64"
INSTALL_PREFIX="$ROOT/install/$PLATFORM/$CFG/occt"
BUILD_DIR="$ROOT/build/occt/linux/$CFG"

[ -f "$OCCT_SRC/CMakeLists.txt" ] || {
  echo "[ERR] OCCT source not found: $OCCT_SRC" >&2
  echo "      Tried: $OCCT_SRC_LOWER and $OCCT_SRC_UPPER" >&2
  exit 1
}

# Bootstrap vcpkg and install dependencies (manifest-driven)
# NOTE: keep the original bootstrap-vcpkg.sh interface (triplet + manifest dir)
sh "$ROOT/scripts/bootstrap-vcpkg.sh" "$TRIPLET" "manifests/occt"

mkdir -p "$BUILD_DIR"

# --- Link fix (Linux): DRAWEXE fails due to missing zlib on link line ---
# Root cause:
#   libTKDraw.so references zlib symbols (crc32/inflate/deflate/...)
#   but DRAWEXE link step does not include -lz, so ld errors out.
# We must NOT modify vendor sources, so we inject a top-level CMake include.
OCCT_FIXUP_CMAKE="$BUILD_DIR/alice_occt_fixup_zlib.cmake"
cat > "$OCCT_FIXUP_CMAKE" <<'CMAKE'
# Alice fixup: ensure OCCT Draw targets link to zlib on Linux.
# Applied via -DCMAKE_PROJECT_INCLUDE=... so vendor sources stay clean.

if(DEFINED ALICE_OCCT_ZLIB_FIXUP_DONE)
  return()
endif()
set(ALICE_OCCT_ZLIB_FIXUP_DONE TRUE)

function(alice_occt_fixup_zlib)
  find_package(ZLIB QUIET)

  foreach(tgt IN ITEMS TKDraw DRAWEXE)
    if(TARGET ${tgt})
      if(TARGET ZLIB::ZLIB)
        target_link_libraries(${tgt} PRIVATE ZLIB::ZLIB)
      else()
        # Fallback to system libz if imported target is unavailable
        target_link_libraries(${tgt} PRIVATE z)
      endif()
    endif()
  endforeach()
endfunction()

# Defer until after subdirectories/targets are defined (requires CMake >= 3.19)
if(COMMAND cmake_language)
  cmake_language(DEFER CALL alice_occt_fixup_zlib)
else()
  message(WARNING "CMake is too old for cmake_language(DEFER); zlib fixup may not run.")
endif()
CMAKE

cmake -S "$OCCT_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE="$CFG" \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/extern/vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_MANIFEST_DIR="$ROOT/manifests/occt" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DCMAKE_PROJECT_INCLUDE="$OCCT_FIXUP_CMAKE" \
  -DBUILD_LIBRARY_TYPE=Shared \
  -DBUILD_TESTING=OFF \
  -DUSE_OPENGL=ON \
  -DUSE_TBB=ON \
  -DUSE_FREETYPE=ON \
  -DUSE_ZLIB=ON

cmake --build "$BUILD_DIR" --target install

echo "[OK] OCCT installed: $INSTALL_PREFIX"
