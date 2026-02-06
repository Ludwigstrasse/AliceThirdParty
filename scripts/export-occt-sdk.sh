#!/usr/bin/env sh
set -eu

TP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${1:-Release}"
SD_ROOT="${2:-$(cd "$TP_ROOT/.." && pwd)}"

PLATFORM="linux-x64"
CFG_DIR="$CFG"

SRC_OCCT="$TP_ROOT/install/$PLATFORM/$CFG_DIR"
SRC_VCPKG_LIB="$TP_ROOT/vcpkg_installed/x64-linux/lib"
SRC_VCPKG_BIN="$TP_ROOT/vcpkg_installed/x64-linux/bin"

DST_SDK="$SD_ROOT/Externals/3rdParty/sdk/$PLATFORM/$CFG_DIR"
DST_RUNTIME="$SD_ROOT/Externals/3rdParty/runtime/$PLATFORM/$CFG_DIR"

echo "[EXPORT] TP_ROOT     = $TP_ROOT"
echo "[EXPORT] SD_ROOT     = $SD_ROOT"
echo "[EXPORT] CFG         = $CFG_DIR"
echo "[EXPORT] SRC_OCCT    = $SRC_OCCT"
echo "[EXPORT] DST_SDK     = $DST_SDK"
echo "[EXPORT] DST_RUNTIME = $DST_RUNTIME"

if [ ! -d "$SRC_OCCT" ]; then
  echo "[ERR] OCCT install prefix not found: $SRC_OCCT" >&2
  echo "      Build OCCT first: ./scripts/build-occt.sh $CFG_DIR" >&2
  exit 1
fi

mkdir -p "$DST_SDK" "$DST_RUNTIME"

echo "[EXPORT] Copy OCCT SDK..."
# Copy full SDK tree
rsync -a --delete "$SRC_OCCT/" "$DST_SDK/"

echo "[EXPORT] Copy OCCT runtime libs..."
# Linux runtime is usually .so files in lib (and sometimes bin)
if [ -d "$SRC_OCCT/lib" ]; then
  rsync -a "$SRC_OCCT/lib/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi
if [ -d "$SRC_OCCT/bin" ]; then
  rsync -a "$SRC_OCCT/bin/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi

echo "[EXPORT] Copy vcpkg runtime libs..."
# On linux, vcpkg runtime libs commonly end up in lib as .so
if [ -d "$SRC_VCPKG_LIB" ]; then
  rsync -a "$SRC_VCPKG_LIB/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi
if [ -d "$SRC_VCPKG_BIN" ]; then
  rsync -a "$SRC_VCPKG_BIN/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi

echo "[OK] Export done."
echo "     SDK:     $DST_SDK"
echo "     Runtime: $DST_RUNTIME"
