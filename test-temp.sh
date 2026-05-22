#!/usr/bin/env bash
set -euo pipefail

HIDRAW6="/dev/hidraw6"

sudo chmod 666 "$HIDRAW6"

cleanup() {
    echo
    echo "==> Restoring permissions on $HIDRAW6..."
    sudo chmod 600 "$HIDRAW6" 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

echo "==> DIRECT MODE: playerctl/pamixer called directly (no uinput)"
echo "==> Turn volume knob, press Fn+2 (Play/Pause), etc."
echo "==> Press Ctrl+C to stop."
"$HOME/.local/bin/dareu-media-daemon" --direct
