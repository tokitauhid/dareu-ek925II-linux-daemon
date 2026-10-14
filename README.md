# Dareu EK925 II Linux Media Daemon

A lightweight user-space driver and service for Linux that restores full functionality to the volume rotary knob and media key shortcuts (`Fn + 1` through `Fn + 0`) on the **Dareu EK925 II** mechanical keyboard.

---

## Overview

The Dareu EK925 II mechanical keyboard contains a firmware flaw in its USB HID report descriptor: the consumer control usage fields are incorrectly marked as constant padding data rather than input data. As a consequence, the Linux kernel's standard HID input driver ignores all media key reports.

This project resolves the issue without kernel patching or out-of-tree kernel modules. A lightweight background service monitors the keyboard's raw HID interface directly, translates consumer control events, and triggers corresponding media and audio actions in real time.

---

## Key Features

- **Full Hardware Support**: Restores the rotary volume knob and all 10 Fn media key combinations.
- **Distro & Desktop Agnostic**: Functions seamlessly under Wayland and X11 across all desktop environments and window managers (Hyprland, Sway, i3, GNOME, KDE Plasma, etc.).
- **Automatic Audio Backend Detection**: Natively integrates with PipeWire/WirePlumber (`wpctl`), PulseAudio (`pactl`), or ALSA (`amixer`).
- **Zero Python Dependencies in Direct Mode**: Runs on Python 3 standard library with asynchronous, non-blocking execution.
- **Dual Operating Modes**: Supports direct MPRIS/audio execution (default) as well as virtual kernel input device emulation via `uinput`.
- **Systemd User Integration**: Runs with user-level privileges; requires root only once for installing the udev rule.

---

## Quick Evaluation (No Installation Required)

To verify functionality before installing the background service, run the temporary test script:

```bash
git clone https://github.com/tokitauhid/dareu-ek925II-linux-daemon.git
cd dareu-ek925II-linux-daemon
bash scripts/test-temp.sh
```

Turn the volume knob or press `Fn + 2` (Play/Pause). Press `Ctrl + C` when finished to automatically restore device permissions.

---

## Installation

### Method 1: Automated One-Line Installer (Recommended)

The automated script detects your distribution's package manager, resolves prerequisites, clones the latest release, and starts the systemd user service:

```bash
curl -fsSL https://raw.githubusercontent.com/tokitauhid/dareu-ek925II-linux-daemon/main/scripts/install-online.sh | bash
```

### Method 2: Manual Installation

```bash
git clone https://github.com/tokitauhid/dareu-ek925II-linux-daemon.git
cd dareu-ek925II-linux-daemon
bash install.sh
```

### Installed Components

| Path | Description |
| :--- | :--- |
| `/etc/udev/rules.d/99-dareu-ek925.rules` | Grants read access to the keyboard's raw HID interface and configures uinput access |
| `~/.local/bin/dareu-media-daemon` | Python daemon binary |
| `~/.config/systemd/user/dareu-media-daemon.service` | Systemd user service unit configured for automatic startup on user login |

### Verifying Service Status

```bash
systemctl --user status dareu-media-daemon.service
```

---

## Dependencies

### Direct Mode (Default)

Direct mode executes media commands natively and requires only Python 3 standard library:

| Dependency | Purpose | Arch Linux | Debian / Ubuntu | Fedora |
| :--- | :--- | :--- | :--- | :--- |
| `python3` | Daemon runtime | Pre-installed | Pre-installed | Pre-installed |
| `playerctl` | MPRIS media playback control | `pacman -S playerctl` | `apt install playerctl` | `dnf install playerctl` |
| `wireplumber` | Audio volume control | `pacman -S wireplumber` | `apt install wireplumber` | `dnf install wireplumber` |

*Note: If `wireplumber` is not present, the daemon automatically falls back to PulseAudio (`pulseaudio-utils` / `pactl`) or ALSA (`alsa-utils` / `amixer`).*

### UInput Mode (Optional)

If running the daemon with `--uinput` to emit virtual kernel key events rather than executing commands directly, the Python evdev module is required:

| Dependency | Arch Linux | Debian / Ubuntu | Fedora |
| :--- | :--- | :--- | :--- |
| `python-evdev` | `pacman -S python-evdev` | `apt install python3-evdev` | `dnf install python3-evdev` |

---

## Key Mapping Reference

| Key Combination | Reported Event | Default Direct Action | Emitted Event Code |
| :--- | :--- | :--- | :--- |
| Rotary Knob (Clockwise) | `KEY_VOLUMEUP` | Volume +5% | `KEY_VOLUMEUP` (115) |
| Rotary Knob (Counter-clockwise) | `KEY_VOLUMEDOWN` | Volume -5% | `KEY_VOLUMEDOWN` (114) |
| `Fn + 1` | `KEY_NEXTSONG` | `playerctl next` | `KEY_NEXTSONG` (163) |
| `Fn + 2` | `KEY_PLAYPAUSE` | `playerctl play-pause` | `KEY_PLAYPAUSE` (164) |
| `Fn + 3` | `KEY_PREVIOUSSONG` | `playerctl previous` | `KEY_PREVIOUSSONG` (165) |
| `Fn + 4` | `KEY_STOPCD` | `playerctl stop` | `KEY_STOPCD` (166) |
| `Fn + 5` | `KEY_MUTE` | Toggle audio mute | `KEY_MUTE` (113) |
| `Fn + 6` | `KEY_VOLUMEUP` | Volume +5% | `KEY_VOLUMEUP` (115) |
| `Fn + 7` | `KEY_VOLUMEDOWN` | Volume -5% | `KEY_VOLUMEDOWN` (114) |
| `Fn + 8` | `KEY_CALC` | Passthrough | `KEY_CALC` (140) |
| `Fn + 9` | `KEY_EMAIL` | Passthrough | `KEY_EMAIL` (215) |
| `Fn + 0` | `KEY_HOMEPAGE` | Passthrough | `KEY_HOMEPAGE` (172) |

### Custom Bindings (Hyprland / Sway / i3)

Keys without a default direct action (`Fn + 8`, `Fn + 9`, `Fn + 0`) can be bound to arbitrary commands in your window manager configuration:

```ini
# Example: Hyprland binding for Calculator (Fn + 8)
bind = , code:148, exec, gnome-calculator

# Example: Hyprland binding for Email (Fn + 9)
bind = , code:215, exec, thunderbird
```

---

## Execution Modes

The daemon binary (`dareu-media-daemon`) supports two operational modes:

| Mode | Flag | Description | Recommendation |
| :--- | :--- | :--- | :--- |
| **Direct Mode** | `--direct` (Default) | Directly issues commands via `playerctl` and your audio mixer (`wpctl`/`pactl`). Fast, lightweight, and independent of desktop focus. | Recommended for everyday use across all distros. |
| **UInput Mode** | *(no flag)* | Creates a virtual input device at `/dev/uinput` and injects standard Linux input event codes into the kernel event subsystem. | Recommended if you prefer managing all bindings inside your compositor or desktop shortcuts settings. |

---

## Troubleshooting

### Inspecting Live Service Logs

To monitor daemon activity and button press detections:

```bash
journalctl --user -u dareu-media-daemon.service -f
```

### Verifying Raw Device Output

To confirm that raw HID reports are being emitted by the keyboard controller:

```bash
bash scripts/raw-test.sh
```

Turn the volume knob or press any media key. A stream of 64-byte hex reports should appear in the terminal.

---

## Technical Details

The Dareu EK925 II keyboard identifies as:
- **Vendor ID**: `260d` (SinoWealth)
- **Product ID**: `0015`
- **Target Interface**: `Interface 1, Report ID 2` (Consumer Control Collection)

### The Descriptor Bug

In the keyboard's USB HID descriptor, 24 Consumer Control usage definitions are declared with the item tag:
```
Input (Const, Var, Abs) -> 0x81 0x03
```
Under the USB HID Specification, the `Const` attribute indicates reserved/padding bits that do not carry meaningful application data. Consequently, the Linux kernel's input driver in [`drivers/hid/hid-input.c`](https://github.com/torvalds/linux/blob/master/drivers/hid/hid-input.c) ignores them during report enumeration.

### Resolution

The daemon accesses the keyboard directly via `/dev/input/by-id/usb-YXTech_Com_Game_Keyboard-if01-hidraw`. It reads the raw 4-byte HID packets, extracts Report ID 2 bitfields, and handles state transitions with bitwise differential masks (`changed = prev ^ cur`).

---

## Uninstallation

To completely remove the daemon, user service, and udev rule from your system:

```bash
bash uninstall.sh
```

---

## License

This project is licensed under the [MIT License](LICENSE).
