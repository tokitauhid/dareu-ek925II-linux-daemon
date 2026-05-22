#!/usr/bin/env bash
# Quick temp test: no install needed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HIDRAW6="/dev/hidraw6"

sudo chmod 666 "$HIDRAW6"

cleanup() {
    echo
    sudo chmod 600 "$HIDRAW6" 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

echo "==> DIRECT MODE: try volume knob and Fn media keys"
echo "==> Press Ctrl+C to stop."
"$SCRIPT_DIR/../src/dareu-media-daemon" --direct
