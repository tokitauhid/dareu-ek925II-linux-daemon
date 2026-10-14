# Dareu EK925 II — Media Keys Fix for Linux

> Make your keyboards volume knob and media keys (Fn+1 through Fn+0) actually work on Linux.

---

## What is this?

If you own a **Dareu EK925 II** keyboard and your media keys do nothing on Linux — this fixes that.

The keyboard has a firmware bug that makes Linux completely ignore its media keys and volume knob. This tool runs quietly in the background and makes them work again, no reboot or kernel patching required.

---

## Quick Test (no install needed)

Want to try it before installing? Run:

```bash
bash scripts/test-temp.sh
```

Then turn the volume knob or press **Fn+2** (Play/Pause). If audio responds, you're good to go!

---

## Installation

### One-line installer (Recommended)

Works on any Linux distribution and window manager / desktop environment (Hyprland, Sway, i3, GNOME, KDE, etc.):

```bash
curl -fsSL https://raw.githubusercontent.com/tokitauhid/dareu-ek925II-linux-daemon/main/scripts/install-online.sh | bash
```

### Manual Installation

Clone the repository and run the install script:

```bash
git clone https://github.com/tokitauhid/dareu-ek925II-linux-daemon.git
cd dareu-ek925II-linux-daemon
bash install.sh
```

### What gets installed?

| File | Purpose |
|------|---------|
| `/etc/udev/rules.d/99-dareu-ek925.rules` | Lets the tool read your keyboard's raw input |
| `~/.local/bin/dareu-media-daemon` | The background worker |
| `~/.config/systemd/user/dareu-media-daemon.service` | Auto-starts it when you log in |

### Check if it's running:

```bash
systemctl --user status dareu-media-daemon.service
```

---

## Uninstallation

To completely remove the daemon, systemd user service, and udev rule:

```bash
bash uninstall.sh
```

---

## Dependencies

Most are already installed or available through your package manager:

| Package | What it's for | Install (Arch) | Install (Debian/Ubuntu) |
|---------|--------------|----------------|--------------------------|
| `playerctl` | Controlling music playback | `sudo pacman -S playerctl` | `sudo apt install playerctl` |
| `wireplumber` | Volume control | Usually pre-installed with PipeWire | Usually pre-installed with PipeWire |
| `python-evdev` | Only needed for uinput mode | `sudo pacman -S python-evdev` | `sudo apt install python3-evdev` |

> Direct mode (the default) uses Python's standard library and does not require `python-evdev`. If `wireplumber` isn't found, the tool automatically falls back to PulseAudio (`pactl`) or ALSA (`amixer`).

---

## Key Mapping

| Key Combo | Action |
|-----------|--------|
| Fn + 1 | Next Track |
| Fn + 2 | Play / Pause |
| Fn + 3 | Previous Track |
| Fn + 4 | Stop |
| Fn + 5 | Mute / Unmute |
| Fn + 6 | Volume Up |
| Fn + 7 | Volume Down |
| Fn + 8 | Calculator *(no default action)* |
| Fn + 9 | Email *(no default action)* |
| Fn + 0 | Homepage *(no default action)* |

> **Hyprland users:** Keys without a default action still emit unique keycodes you can bind yourself, e.g. `bind = , code:240, exec, your-command`

---

## Two Modes

| Mode | How it works | Best for |
|------|-------------|----------|
| **Direct** *(default)* | Calls audio tools directly | Works reliably on any distro |
| **uinput** | Emulates real keypresses | Works system-wide in any app |

The default mode works for most people. You don't need to change anything.

---

## Why does this happen?

The keyboard's firmware mislabels its media keys as "unused padding" in its USB descriptor. Linux follows the spec strictly and ignores them. Windows doesn't care about the spec and reads them anyway.

This tool bypasses the broken descriptor entirely, reading the raw data directly from the keyboard.

<details>
<summary>Deep technical details</summary>

The bug is in **Interface 1, Report ID 2** (Consumer Control collection). All 24 media/application usage fields incorrectly use `Input (Const,Var,Abs)` (`0x81 0x03`) instead of `Input (Data,Var,Abs)` (`0x81 0x02`). The Linux kernel skips constant fields in [`hid-input.c`](https://github.com/torvalds/linux/blob/master/drivers/hid/hid-input.c) (~line 1217). The keyboard uses a SinoWealth controller (vendor ID `260d`).

</details>

---

## License

MIT — free to use, modify, and share.
