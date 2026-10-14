#!/usr/bin/env bash
# Uninstall Dareu EK925 II media keys daemon
set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Error: Do not run uninstall.sh with sudo or as root." >&2
    echo "Run: bash uninstall.sh" >&2
    echo "The script will prompt for sudo when removing system udev rules." >&2
    exit 1
fi

UDEV_DEST="/etc/udev/rules.d/99-dareu-ek925.rules"
BIN_DEST="$HOME/.local/bin/dareu-media-daemon"
SERVICE_DEST="$HOME/.config/systemd/user/dareu-media-daemon.service"

echo "==> Stopping and disabling service..."
systemctl --user disable --now dareu-media-daemon.service 2>/dev/null || true

echo "==> Removing user files..."
rm -f "$SERVICE_DEST"
rm -f "$BIN_DEST"
systemctl --user daemon-reload
systemctl --user reset-failed 2>/dev/null || true

echo "==> Removing udev rules..."
if [ -f "$UDEV_DEST" ]; then
    sudo rm -f "$UDEV_DEST"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

echo "==> Done! Dareu EK925 II daemon has been uninstalled."
