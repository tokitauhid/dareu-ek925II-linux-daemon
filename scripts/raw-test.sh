#!/usr/bin/env bash
# Verify raw HID data arrives from the keyboard
set -euo pipefail

HIDRAW6="/dev/hidraw6"
sudo chmod 666 "$HIDRAW6"

echo "Reading raw HID reports from $HIDRAW6..."
echo "Turn the volume knob or press Fn+2 (Play/Pause)."
echo "Press Ctrl+C to stop."
echo ""

sudo cat "$HIDRAW6" | hexdump -C -n 64
