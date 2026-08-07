# Scripts

All custom scripts. Utility scripts live in `scripts/` and are symlinked into `~/.config/wallust/`. Waybar scripts live in `waybar/scripts/`.

## Utility Scripts (`scripts/` → `~/.config/wallust/`)

10 core scripts for theming and recording.

### `wallpaper-select.sh`

Rofi-based wallpaper picker with grid thumbnails.

```bash
~/.config/wallust/wallpaper-select.sh                    # Open picker UI
~/.config/wallust/wallpaper-select.sh /path/to/image.jpg  # Direct set
~/.config/wallust/wallpaper-select.sh --live              # Live picker only
```

**Features:**
- Main menu with Static / Live wallpaper options (themed SVG icons)
- Grid display with thumbnails (static) and ffmpeg-generated thumbnails (live)
- Cached theme switching — uses pre-generated palettes when available
- Backup/restore safety on all theme generations
- Restarts waybar after theme change
- **Bound to**: `SUPER + SHIFT + W`

### `reload-theme.sh`

Applies the generated theme to all running components without killing apps.

```bash
~/.config/wallust/reload-theme.sh
```

**What it does:**
1. Sources color env vars from `wallust/env`
2. Fixes `~` expansion in `qt6ct/qt6ct.conf`
3. Reloads swaync CSS in-place (`swaync-client --reload-css`)
4. Updates Hyprland border colors live via `hyprctl eval`

### `cache-wallpapers.sh`

One-shot pre-cache of all wallpapers.

```bash
~/.config/wallust/cache-wallpapers.sh
```

Generates wallust palettes and thumbnails for every static and live wallpaper in the directories.

### `wallust-cache-daemon.sh`

Event-driven background cache daemon (run by systemd).

```bash
systemctl --user status wallust-cache-daemon.service
```

- Watches wallpaper directories with `inotifywait`
- Debounces rapid file changes
- Pre-generates palettes in background (Nice=19, idle IO)
- 24-hour failure cooldown for problematic images
- File locking for single-instance safety

### `record-fullscreen.sh`

Toggle fullscreen screen recording.

- **Trigger**: `SUPER + R`
- **Output**: `~/Videos/Recordings/Fullscreen/recording_YYYYMMDD_HHMMSS.mp4`
- **Audio**: Desktop audio (default sink monitor)
- **Guard**: Atomic `mkdir` debounce + `pgrep -x wf-recorder` cross-type guard
- **Notifications**: Shows start/stop notifications

### `record-region.sh`

Toggle region screen recording.

- **Trigger**: `SUPER + SHIFT + R`
- **Selection**: `slurp` — click and drag to select area
- **Output**: `~/Videos/Recordings/Region/recording_YYYYMMDD_HHMMSS.mp4`
- **Audio**: Desktop audio only
- **Guard**: Same as fullscreen script

### `recording-indicator.sh`

Waybar module that blinks when recording is active.

- **Trigger**: Polled by waybar every 10s
- **Mechanism**: Checks `pgrep -x wf-recorder`
- **Output**: Waybar JSON with text and CSS class

### `hyprlock-setup.sh`

Generates a basic `hyprlock.conf` from the current wallpaper.

```bash
~/.config/wallust/hyprlock-setup.sh
```

- Uses current wallpaper as lock screen background
- Sets JetBrainsMono font for clock/date

### `workspace-monitor.sh`

Background helper that pushes instant waybar workspace updates on Hyprland workspace events (used by autostart).

### `hyprlogout`

Wrapper used by the power menu / wlogout to exit Hyprland cleanly.

### `wifi-fix.sh`

Boot-time WiFi stabilizer, run from `hypr/autostart.lua` shortly after login.

- Waits for NetworkManager to appear on D-Bus (up to 30s)
- Unblocks the WiFi radio (`rfkill unblock wifi`, `nmcli radio wifi on`)
- Waits for an active connection, then reactivates saved connections if needed
- Retries with a radio toggle if still offline

Fixes the boot-time "strikethrough WiFi" waybar icon and impala crashes when NetworkManager isn't ready yet.

## Waybar Scripts (`waybar/scripts/`)

17 scripts powering the waybar custom modules:

| Script | Purpose |
|--------|---------|
| `brightness.sh` | Current brightness % with 4-tier icon (JSON) |
| `brightness-adjust.sh` | Adjust brightness up/down (scroll handler) |
| `launch.sh` | Ensures waybar + swaync are running |
| `media.sh` | playerctl metadata follower (artist/title/status) |
| `notification.sh` | Bell icon with DnD/notification count |
| `power-profile.sh` | Active UPower power profile (D-Bus) |
| `power-profile-switch.sh` | Cycle to next power profile |
| `system-power.sh` | Rofi power menu (Lock/Logout/Sleep/Reboot/Shutdown) |
| `tui-audio.sh` | Opens pulsemixer in floating kitty |
| `tui-bluetooth.sh` | Opens bluetui in floating kitty |
| `tui-wifi.sh` | Waits for NetworkManager, then opens impala in floating kitty |
| `tui-cpu.sh` | Opens btop in floating kitty |
| `weather.sh` | Weather from wttr.in (30-min cache) |
| `workspaces.sh` | Batch workspace display (5 at a time) |
| `workspace-click.sh` | Focus clicked workspace (pixel offset) |
| `workspace-next.sh` | Focus next workspace |
| `workspace-prev.sh` | Focus previous workspace |

## Rofi Scripts (`rofi/scripts/`)

### `system-power.sh`

Power management menu with themed SVG icons.

```bash
~/.config/rofi/scripts/system-power.sh
```

Options: **Lock** (hyprlock), **Logout** (hyprlogout), **Sleep** (systemctl suspend), **Reboot** (systemctl reboot), **Shutdown** (systemctl poweroff), **Cancel**.

- **Bound to**: `SUPER + P`

### `clipboard.sh`

Clipboard history manager.

```bash
~/.config/rofi/scripts/clipboard.sh              # copy mode
~/.config/rofi/scripts/clipboard.sh --delete      # delete mode
```

- Lists recent entries from cliphist
- Copy mode (`SUPER + V`): copies selected entry to clipboard
- Delete mode (`SUPER + SHIFT + V`): removes entry
- Starts cliphist store daemon if not running

### `script_wallpaper.sh`

Legacy single-column wallpaper picker (grid theme, awww transitions). Installs to `~/.config/rofi/launchers/type-6/` integration.

## Script Conventions

- **Debounce mechanism** — Atomic `mkdir` to prevent double-firing (Hyprland sometimes fires keybinds twice)
- **Cross-type guards** — `pgrep -x wf-recorder` prevents overlapping recording types
- **Notifications** — All actions send desktop notifications via `notify-send`
