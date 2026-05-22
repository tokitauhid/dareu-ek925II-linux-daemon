#!/usr/bin/env bash
set -euo pipefail

UDEV_DEST="/etc/udev/rules.d/99-dareu-ek925.rules"

echo "==> Installing udev rule..."
if [ -f "$UDEV_DEST" ]; then
    echo "WARNING: $UDEV_DEST already exists, backing up to ${UDEV_DEST}.bak"
    sudo cp "$UDEV_DEST" "${UDEV_DEST}.bak"
fi
sudo cp "$(dirname "$0")/99-dareu-ek925.rules" "$UDEV_DEST"
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "==> Applying permissions to existing hidraw6..."
sudo chown tokit /dev/hidraw6 2>/dev/null || true
sudo chmod 660 /dev/hidraw6 2>/dev/null || true

echo "==> Enabling user service..."
mkdir -p "$HOME/.config/systemd/user"
cp "${0%/*}/../systemd/user/dareu-media-daemon.service" "$HOME/.config/systemd/user/" 2>/dev/null || \
    cp "$(dirname "$0")/dareu-media-daemon.service" "$HOME/.config/systemd/user/"

systemctl --user daemon-reload
systemctl --user enable --now dareu-media-daemon.service

echo "==> Done! Status:"
systemctl --user status dareu-media-daemon.service --no-pager
