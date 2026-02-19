#!/bin/bash
# Start VisualGST IDE
# Usage: ./start_vgst.sh [DISPLAY]
#   e.g. ./start_vgst.sh :1

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export DISPLAY="${1:-${DISPLAY:-:0}}"
export LTDL_LIBRARY_PATH="$SCRIPT_DIR/packages/glib/.libs:$SCRIPT_DIR/packages/gtk/.libs:$SCRIPT_DIR/packages/cairo/.libs"

exec "$SCRIPT_DIR/gst" --no-user-files --kernel-dir "$SCRIPT_DIR/kernel" --image "$SCRIPT_DIR/gst.im" "$SCRIPT_DIR/start_vgst.st"
