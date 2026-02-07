#!/usr/bin/env sh
set -eu

TP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Args (keep same convention as original export-occt-sdk.sh):
CFG="${1:-Release}"
SD_ROOT="${2:-$(cd "$TP_ROOT/.." && pwd)}"

# Optional: override vcpkg manifest dir (defaults to TP_ROOT)
MANIFEST_DIR="${3:-$TP_ROOT}"

PLATFORM="linux-x64"
TRIPLET="x64-linux"
CFG_DIR="$CFG"

PKG="vtk"

# Prefer per-package install prefix
SRC_PREFIX="$TP_ROOT/install/$PLATFORM/$CFG_DIR/$PKG"
if [ ! -d "$SRC_PREFIX" ]; then
  SRC_PREFIX="$TP_ROOT/install/$PLATFORM/$CFG_DIR"
  echo "[WARN] per-package install prefix not found, fallback to legacy: $SRC_PREFIX" >&2
fi

SRC_VCPKG_LIB="$MANIFEST_DIR/vcpkg_installed/$TRIPLET/lib"
SRC_VCPKG_BIN="$MANIFEST_DIR/vcpkg_installed/$TRIPLET/bin"

DST_SDK="$SD_ROOT/Externals/3rdParty/sdk/$PLATFORM/$CFG_DIR/$PKG"
DST_RUNTIME="$SD_ROOT/Externals/3rdParty/runtime/$PLATFORM/$CFG_DIR/$PKG"

echo "[EXPORT] TP_ROOT      = $TP_ROOT"
echo "[EXPORT] SD_ROOT      = $SD_ROOT"
echo "[EXPORT] CFG          = $CFG_DIR"
echo "[EXPORT] PKG          = $PKG"
echo "[EXPORT] SRC_PREFIX   = $SRC_PREFIX"
echo "[EXPORT] MANIFEST_DIR = $MANIFEST_DIR"
echo "[EXPORT] DST_SDK      = $DST_SDK"
echo "[EXPORT] DST_RUNTIME  = $DST_RUNTIME"

if [ ! -d "$SRC_PREFIX" ]; then
  echo "[ERR] Install prefix not found: $SRC_PREFIX" >&2
  exit 1
fi

command -v rsync >/dev/null 2>&1 || { echo "[ERR] rsync not found (please install rsync)."; exit 1; }

mkdir -p "$DST_SDK" "$DST_RUNTIME"

echo "[EXPORT] Copy $PKG SDK."
rsync -a --delete "$SRC_PREFIX/" "$DST_SDK/"

echo "[EXPORT] Copy $PKG runtime libs."
if [ -d "$SRC_PREFIX/lib" ]; then
  rsync -a "$SRC_PREFIX/lib/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi
if [ -d "$SRC_PREFIX/bin" ]; then
  rsync -a "$SRC_PREFIX/bin/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi

echo "[EXPORT] Copy vcpkg runtime libs."
if [ -d "$SRC_VCPKG_LIB" ]; then
  rsync -a "$SRC_VCPKG_LIB/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi
if [ -d "$SRC_VCPKG_BIN" ]; then
  rsync -a "$SRC_VCPKG_BIN/" "$DST_RUNTIME/" --include='*.so*' --exclude='*'
fi

echo "[OK] Export done."
echo "     SDK:     $DST_SDK"
echo "     Runtime: $DST_RUNTIME"
