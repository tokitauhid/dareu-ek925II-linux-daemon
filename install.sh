#!/usr/bin/env bash
# Install Dareu EK925 II media keys daemon
set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Error: Do not run install.sh with sudo or as root." >&2
    echo "Run: bash install.sh" >&2
    echo "The script will prompt for sudo when installing system udev rules." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UDEV_DEST="/etc/udev/rules.d/99-dareu-ek925.rules"
BIN_DEST="$HOME/.local/bin/dareu-media-daemon"
SERVICE_DEST="$HOME/.config/systemd/user/dareu-media-daemon.service"

echo "==> Installing udev rule..."
if [ -f "$UDEV_DEST" ]; then
    sudo cp "$UDEV_DEST" "${UDEV_DEST}.bak"
fi
sudo cp "$SCRIPT_DIR/udev/99-dareu-ek925.rules" "$UDEV_DEST"
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "==> Installing daemon..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/src/dareu-media-daemon" "$BIN_DEST"
chmod +x "$BIN_DEST"

echo "==> Installing systemd user service..."
mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/systemd/dareu-media-daemon.service" "$SERVICE_DEST"

systemctl --user daemon-reload
systemctl --user enable --now dareu-media-daemon.service

echo "==> Done!"
systemctl --user status dareu-media-daemon.service --no-pager
