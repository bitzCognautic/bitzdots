# Scripts

Reference for all scripts in bitzdots.

## Waybar Scripts (`waybar/scripts/`)

24 scripts powering the waybar custom modules.

| Script | Purpose | Used By |
|--------|---------|---------|
| `brightness.sh` | Outputs current brightness % with 4-tier icon as JSON | `custom/brightness` |
| `launch.sh` | Ensures waybar + swaync are running | Autostart |
| `media.sh` | playerctl metadata follower (artist/title/album/status) | `custom/media` |
| `media-control.sh` | JSON output for prev/next buttons | Media controls |
| `notification.sh` | Bell icon with DnD/notification count | `custom/notification` |
| `power-profile.sh` | Queries UPower via D-Bus for active profile icon | `custom/power-profiles` |
| `power-profile-switch.sh` | Cycles to next available power profile via D-Bus | Click handler |
| `system-power.sh` | Rofi power menu (Lock/Logout/Sleep/Reboot/Shutdown) | `custom/power` |
| `system-audio.sh` | Rofi audio device switcher | PulseAudio click |
| `system-bluetooth.sh` | Rofi bluetooth manager | Bluetooth click |
| `system-wifi.sh` | Rofi WiFi network selector | Network click |
| `system-cpu.sh` | Rofi system monitor launcher | CPU click |
| `system-memory.sh` | Shows `free -h` output | Memory click |
| `tui-audio.sh` | Opens pulsemixer in floating kitty | Audio click (waybar) |
| `tui-bluetooth.sh` | Opens bluetui in floating kitty | Bluetooth click (waybar) |
| `tui-wifi.sh` | Opens impala in floating kitty | Network click (waybar) |
| `tui-cpu.sh` | Opens btop in floating kitty | CPU click (waybar) |
| `tui-launch.sh` | Generic TUI launcher with fallback | Internal |
| `weather.sh` | Fetches weather from wttr.in (30-min cache) | Optional module |
| `workspaces.sh` | Batch workspace display (5 at a time) | `custom/workspaces` |
| `workspace-click.sh` | Determines clicked workspace from pixel offset | Workspace click |
| `workspace-next.sh` | Focus next workspace | Scroll up |
| `workspace-prev.sh` | Focus previous workspace | Scroll down |
| `workspace-names.sh` | Daemon for workspace name formatting | (standalone) |

## Utility Scripts (`scripts/`)

8 core scripts for theming and recording.

### `reload-theme.sh`

Applies the generated theme to all running components.

```bash
~/.config/wallust/reload-theme.sh
```

**What it does:**
1. Reloads swaync CSS (`swaync-client --reload-css`)
2. Updates Hyprland border colors from `colors.lua`
3. Fixes qt6ct config path if needed
4. Restarts waybar for full refresh

### `wallpaper-select.sh`

Rofi-based wallpaper picker with grid thumbnails.

```bash
~/.config/wallust/wallpaper-select.sh                    # Open picker UI
~/.config/wallust/wallpaper-select.sh /path/to/image.jpg  # Direct set
```

**Features:**
- Grid display of all wallpapers with ImageMagick thumbnails
- Separate sections for static wallpapers and live wallpapers
- Cached theme switching — uses pre-generated palettes when available
- Backup/restore safety on all theme generations
- Restarts waybar after theme change

### `cache-wallpapers.sh`

One-shot pre-cache all wallpapers.

```bash
~/.config/wallust/cache-wallpapers.sh
```

Generates wallust palettes and ImageMagick thumbnails for every wallpaper in the directories.

### `wallust-cache-daemon.sh`

Event-driven background cache daemon.

```bash
~/.config/wallust/wallust-cache-daemon.sh
```

**Features:**
- Watches wallpaper directories with `inotifywait`
- Debounces rapid file changes
- Pre-generates palettes in background
- 24-hour failure cooldown for problematic images
- File locking for single-instance safety
- Runs at idle priority (Nice=19)

### `record-fullscreen.sh`

Toggle fullscreen screen recording.

```bash
~/.config/wallust/record-fullscreen.sh
```

- Uses `wf-recorder` with audio (pulse audio)
- Toggles: first call starts, second call stops
- Saves to `~/Videos/Recordings/Fullscreen/` with timestamped filename
- Shows start/stop notifications

### `record-region.sh`

Toggle region screen recording.

```bash
~/.config/wallust/record-region.sh
```

- Uses `slurp` for region selection + `wf-recorder` with audio
- Same toggle behavior as fullscreen
- Saves to `~/Videos/Recordings/Region/`

### `recording-indicator.sh`

Blinking indicator for waybar recording module.

- Called by waybar polling (10s interval)
- Outputs empty JSON when not recording
- Alternates between empty and icon JSON when recording (creates blink effect)

### `hyprlock-setup.sh`

Generates a basic `hyprlock.conf` from current wallpaper.

```bash
~/.config/wallust/hyprlock-setup.sh
```

- Uses current wallpaper as lock screen background
- Sets JetBrainsMono font for the clock/date

## Rofi Scripts (`rofi/scripts/`)

### `clipboard.sh`

Clipboard history manager.

```bash
~/.config/rofi/scripts/clipboard.sh
```

- Lists recent clipboard entries from cliphist
- Decodes and copies selected entry back to clipboard
- Starts cliphist store daemon if not running
- Keyboard navigable via rofi

### `system-power.sh`

Power management menu.

```bash
~/.config/rofi/scripts/system-power.sh
```

Options:
- **Lock** — `hyprlock`
- **Logout** — `hyprctl dispatch exit`
- **Sleep** — `systemctl suspend`
- **Reboot** — `systemctl reboot`
- **Shutdown** — `systemctl poweroff`
- **Cancel** — Close menu

Uses themed SVG icons from rofi icons directory.
