#!/usr/bin/env bash
# Quick temp test: no install needed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEVICE_LINK="/dev/input/by-id/usb-YXTech_Com_Game_Keyboard-if01-hidraw"

if [ ! -e "$DEVICE_LINK" ]; then
    echo "Error: Keyboard device not found at $DEVICE_LINK" >&2
    echo "Make sure the Dareu EK925 II keyboard is plugged in." >&2
    exit 1
fi

HIDRAW="$(readlink -f "$DEVICE_LINK")"

sudo chmod 666 "$HIDRAW"

cleanup() {
    echo
    sudo chmod 600 "$HIDRAW" 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

echo "==> DIRECT MODE: try volume knob and Fn media keys"
echo "==> Press Ctrl+C to stop."
"$SCRIPT_DIR/../src/dareu-media-daemon" --direct
