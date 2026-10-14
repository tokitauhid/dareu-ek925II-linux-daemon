#!/usr/bin/env bash
# Verify raw HID data arrives from the keyboard
set -euo pipefail

DEVICE_LINK="/dev/input/by-id/usb-YXTech_Com_Game_Keyboard-if01-hidraw"

if [ ! -e "$DEVICE_LINK" ]; then
    echo "Error: Keyboard device not found at $DEVICE_LINK" >&2
    echo "Make sure the Dareu EK925 II keyboard is plugged in." >&2
    exit 1
fi

HIDRAW="$(readlink -f "$DEVICE_LINK")"
sudo chmod 666 "$HIDRAW"

echo "Reading raw HID reports from $HIDRAW..."
echo "Turn the volume knob or press Fn+2 (Play/Pause)."
echo "Press Ctrl+C to stop."
echo ""

sudo cat "$HIDRAW" | hexdump -C -n 64
