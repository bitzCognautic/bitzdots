# Waybar Modules

Complete documentation for all waybar modules in bitzdots.

## Layout

```
Left:    custom/workspaces | custom/runcat | custom/media
Center:  clock
Right:   tray | custom/recording | custom/brightness | pulseaudio |
         cpu | memory | custom/power-profiles | custom/notification |
         network | bluetooth | custom/power
```

## Custom Modules

### custom/workspaces

Batch-based workspace display showing 5 workspaces at a time, centered on the active one.

- **Script**: `waybar/scripts/workspaces.sh`
- **Poll interval**: 3 seconds
- **Icons**: `[N]` = active, `|N|` = occupied, `N` = empty
- **Click**: Focus workspace (via `workspace-click.sh`)
- **Scroll**: Cycle workspaces (prev/next)

### custom/runcat

CPU activity animation — a running cat that speeds up when CPU is busy.

- **Script**: `waybar/modules/runcat-text/main.py` (Python)
- **Output**: JSON with emoji/text animation based on CPU usage
- **Disable**: Remove from `modules-left` in config.jsonc for low-end systems

### custom/media

Now-playing media display with playerctl integration.

- **Script**: `waybar/scripts/media.sh`
- **Format**: `icon artist - title` (truncated to 20 chars)
- **Artists with ": "**: Artist ignored (shows only title for podcast-style metadata)
- **On startup**: Kills any stale `playerctl metadata --follow` processes to prevent CPU leaks
- **Click**: Play/Pause
- **Right click**: Stop
- **Scroll**: Next/Previous track

### custom/recording

Screen recording indicator — blinks when `wf-recorder` is active.

- **Script**: `waybar/scripts/recording-indicator.sh`
- **Poll interval**: 10 seconds
- **Output**: Empty string normally, blinking icon (alternates) when recording

### custom/brightness

Display backlight control.

- **Script**: `waybar/scripts/brightness.sh`
- **Poll interval**: 5 seconds
- **Timeout**: 2 seconds on `brightnessctl` calls (prevents hangs)
- **Icons**: 4 levels (full, high, low, off) + percentage
- **Scroll**: Adjust brightness by ±5%

### custom/power-profiles

UPower power profile management (power-saver / balanced / performance).

- **Script**: `waybar/scripts/power-profile.sh`
- **Poll interval**: 30 seconds
- **Implementation**: Uses `busctl` directly on the UPower D-Bus interface (avoids `powerprofilesctl` which can hang at 100% CPU)
- **Icons**: 3 levels (performance, balanced, power-saver)
- **Click**: Cycle to next profile via `power-profile-switch.sh`

### custom/notification

Notification center toggle.

- **Script**: `waybar/scripts/notification.sh`
- **Poll interval**: 10 seconds
- **Click**: Toggle notification panel (`swaync-client -t`)
- **Right click**: Toggle Do Not Disturb (`swaync-client -d`)

### custom/power

Power menu trigger.

- **No script** — uses format + `on-click` directly
- **Click**: Opens rofi power menu (`system-power.sh`)
- **Options**: Lock, Logout, Sleep, Reboot, Shutdown, Cancel

## Built-in Modules

### clock

- **Format**: `{:%a %b %d  %I:%M %p}`
- **Interval**: 30 seconds
- **Tooltip**: Calendar with date

### network

- **Icons**: 󰤨 (WiFi), 󰈀 (ethernet), 󰤮 (disconnected), 󰤭 (no connection)
- **Format**: `{icon}  {bandwidthDownBits}` / `{bandwidthUpBits}`
- **Click**: opens `impala` WiFi TUI via `tui-wifi.sh`
- **Interval**: 10 seconds

### bluetooth

- **Icons**: 󰂯 (off), 󰂱 (on, no connection), 󰂲 (connected)
- **Click**: opens `bluetui` via `tui-bluetooth.sh`
- **Format**: `{icon}`

### pulseaudio

- **Icons**: 󰕾 (high), 󰖀 (mid), 󰕿 (low), 󰝟 (muted)
- **Format**: `{icon} {volume}%`
- **Click**: opens `pulsemixer` via `tui-audio.sh`
- **Scroll**: Volume ±5%

### cpu

- **Format**: ` {usage}%`
- **Click**: opens `btop` via `tui-cpu.sh`
- **Interval**: 5 seconds

### memory

- **Format**: ` {percentage}%`
- **Click**: opens `btop`
- **Interval**: 10 seconds

### tray

- Standard system tray for background apps
- Spacing between items: 8px

## Adding a Custom Module

```jsonc
"custom/my-module": {
  "exec": "~/.config/waybar/scripts/my-script.sh",
  "interval": 10,
  "return-type": "json",
  "on-click": "some-command",
  "on-scroll-up": "command-up",
  "on-scroll-down": "command-down"
}
```

The script should output JSON:
```json
{"text": "display text", "tooltip": "hover text", "class": "optional-css-class", "alt": "alt-text"}
```

## Troubleshooting

### Module not updating

```bash
pkill -x waybar && waybar &
```

### Script errors

Check the waybar logs:
```bash
journalctl --user -u waybar -f
```
