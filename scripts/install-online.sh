#!/usr/bin/env bash
# Universal Installer for Dareu EK925 II Media Keys Daemon
# Works on any Linux distribution and desktop environment / window manager.
set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Error: Do not run this script with sudo or as root." >&2
    echo "It configures user-level services. Sudo will be requested when needed." >&2
    exit 1
fi

echo "=========================================================="
echo "  Dareu EK925 II Linux Daemon — Universal Installer"
echo "=========================================================="

# 1. Detect package manager and install dependencies
install_deps() {
    echo "==> Detecting package manager and installing dependencies..."
    if command -v pacman >/dev/null 2>&1; then
        echo "--> Detected Arch-based distribution (pacman)"
        sudo pacman -S --needed --noconfirm git python playerctl
    elif command -v apt-get >/dev/null 2>&1; then
        echo "--> Detected Debian/Ubuntu-based distribution (apt)"
        sudo apt-get update -qq
        sudo apt-get install -y git python3 playerctl
    elif command -v dnf >/dev/null 2>&1; then
        echo "--> Detected Fedora/RHEL-based distribution (dnf)"
        sudo dnf install -y git python3 playerctl
    elif command -v zypper >/dev/null 2>&1; then
        echo "--> Detected openSUSE distribution (zypper)"
        sudo zypper --non-interactive install git python3 playerctl
    elif command -v xbps-install >/dev/null 2>&1; then
        echo "--> Detected Void Linux (xbps)"
        sudo xbps-install -Sy git python3 playerctl
    elif command -v apk >/dev/null 2>&1; then
        echo "--> Detected Alpine Linux (apk)"
        sudo apk add git python3 playerctl bash
    else
        echo "--> Notice: Package manager not recognized. Checking required commands..."
        if ! command -v git >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
            echo "Error: Please install 'git' and 'python3' before proceeding." >&2
            exit 1
        fi
        if ! command -v playerctl >/dev/null 2>&1; then
            echo "Warning: 'playerctl' not found. Media key actions may not work until playerctl is installed." >&2
        fi
    fi
}

install_deps

# 2. Clone repo to temporary directory and run installer
TMP_DIR="$(mktemp -d -t dareu-install-XXXXXX)"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

echo "==> Fetching latest repository files..."
git clone --depth=1 https://github.com/tokitauhid/dareu-ek925II-linux-daemon.git "$TMP_DIR"

echo "==> Running installer..."
bash "$TMP_DIR/install.sh"

echo "=========================================================="
echo "  Installation complete! Media keys and knob are now active."
echo "=========================================================="
