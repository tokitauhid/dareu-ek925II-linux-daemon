# Dareu EK925 II Media Keys for Linux

Fixes the non-functional volume knob and Fn media keys (Fn+1..0) on the **Dareu EK925 II** mechanical keyboard for Linux.

## The Problem

The keyboard's HID report descriptor marks 23 media/shortcut key fields as **`Const`** (padding) instead of **`Data`**. The Linux kernel's HID parser (`hid-input`) skips Const fields entirely — no input events are generated, regardless of what the hardware sends. The keys work on Windows because its HID driver is more lenient.

This is a **firmware bug** in the keyboard's SinoWealth controller (vendor `260d`).

## How It Works

A userspace daemon (`dareu-media-daemon`) reads raw HID reports from `/dev/hidraw6` and translates them into keystrokes:

```
┌─────────────┐   raw HID    ┌──────────────────┐   evdev/uinput    ┌───────────┐
│  Keyboard    │ ──────────→  │  dareu-media-    │ ────────────────→ │  System   │
│  (hidraw6)   │   (bypasses  │  daemon          │   (or direct      │  (player  │
│              │    broken    │                  │    cmd)           │   volume) │
└─────────────┘   descriptor) └──────────────────┘                   └───────────┘
```

Two modes:

| Mode | How it works | When to use |
|------|-------------|-------------|
| `--direct` (default) | Calls `playerctl`/`wpctl`/`pactl`/`amixer` directly | Reliable, works on any distro |
| uinput (no flag) | Injects evdev events via `/dev/uinput` | System-wide, keys work in any app |

## File Structure

```
├── install.sh             # Installation script
├── src/
│   └── dareu-media-daemon # The daemon
├── systemd/
│   └── dareu-media-daemon.service  # systemd user service
├── udev/
│   └── 99-dareu-ek925.rules       # udev rules
├── scripts/
│   ├── raw-test.sh        # Verify raw HID data arrives
│   └── test-temp.sh       # Quick temp test (no install)
└── README.md
```

## Quick Test

```bash
bash scripts/test-temp.sh
```

Turn the volume knob or press Fn+2 (Play/Pause). Should control audio immediately.

## Installation

```bash
bash install.sh
```

This installs:
- `/etc/udev/rules.d/99-dareu-ek925.rules` — grants daemon access to raw HID
- `~/.local/bin/dareu-media-daemon` — the daemon
- `~/.config/systemd/user/dareu-media-daemon.service` — auto-start via systemd

### Post-install

Check status:

```bash
systemctl --user status dareu-media-daemon.service
journalctl --user -u dareu-media-daemon.service -f
```

### Dependencies

Installed automatically on most distros or via your package manager:

| Package | Purpose | Install command |
|---------|---------|-----------------|
| `python-evdev` | uinput support | `sudo pacman -S python-evdev` (Arch) / `sudo apt install python3-evdev` (Debian) |
| `playerctl` | Media playback control | `sudo pacman -S playerctl` / `sudo apt install playerctl` |
| `wireplumber` | Volume control (auto-detected) | Usually pre-installed with PipeWire |

If `wireplumber` isn't available, the daemon falls back to `pulseaudio-utils` (pactl) or `alsa-utils` (amixer).

## Fn Key Mapping

The daemon recognizes these key combinations (based on the raw HID report):

| Fn combo | Key | Action |
|----------|-----|--------|
| Fn+1 | Next Track | `playerctl next` |
| Fn+2 | Play/Pause | `playerctl play-pause` |
| Fn+3 | Previous Track | `playerctl previous` |
| Fn+4 | Stop | `playerctl stop` |
| Fn+5 | Mute | `wpctl set-mute ... toggle` |
| Fn+6 | Volume Up | `wpctl set-volume ... 5%+` |
| Fn+7 | Volume Down | `wpctl set-volume ... 5%-` |
| Fn+8 | Calculator | (no default action) |
| Fn+9 | Email | (no default action) |
| Fn+0 | Homepage | (no default action) |

Any Fn keys without a mapped action emit evdev keycodes (reserved range 240+) that you can bind in your compositor (Hyprland: `bind = , code:240, exec, ...`).

## Technical Details

The HID descriptor issue is in the device's **Interface 1, Report ID 2** (Consumer Control collection). All 24 media/application usage fields use `Input (Const,Var,Abs)` (`0x81 0x03`) instead of `Input (Data,Var,Abs)` (`0x81 0x02`). Relevant kernel code: [`drivers/hid/hid-input.c`](https://github.com/torvalds/linux/blob/master/drivers/hid/hid-input.c) line ~1217 — fields with `HID_MAIN_ITEM_CONSTANT` are skipped.

## License

MIT
