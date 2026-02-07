#!/usr/bin/env sh
set -eu

CFG="${1:-Release}"
SD_ROOT="${2:-}"
MANIFEST_DIR="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/export-occt-sdk.sh" "$CFG" "$SD_ROOT" "$MANIFEST_DIR"
"$SCRIPT_DIR/export-ogre-sdk.sh" "$CFG" "$SD_ROOT" "$MANIFEST_DIR"
"$SCRIPT_DIR/export-osg-sdk.sh"  "$CFG" "$SD_ROOT" "$MANIFEST_DIR"
"$SCRIPT_DIR/export-vtk-sdk.sh"  "$CFG" "$SD_ROOT" "$MANIFEST_DIR"
"$SCRIPT_DIR/export-skylark-sdk.sh" "$CFG" "$SD_ROOT" "$MANIFEST_DIR"

echo "[OK] Export all done."
