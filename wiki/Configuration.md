# Configuration

## File Structure

All configuration files live under `~/.config/`:

```
~/.config/
├── fish/
│   └── config.fish          # Shell configuration
├── fastfetch/
│   ├── config.jsonc          # Fastfetch config
│   └── bitz.txt              # Custom BITZ ASCII logo
├── hypr/
│   ├── keybinds.lua          # Keyboard shortcuts
│   ├── rules.lua             # Window rules
│   ├── appearance.lua        # Theme settings
│   ├── monitors.lua          # Display configuration
│   └── hyprland.conf         # Main entry point
├── rofi/
│   ├── app-launcher.rasi     # App launcher style
│   ├── clipboard.rasi        # Clipboard style
│   ├── emoji.rasi            # Emoji picker style
│   └── powermenu.rasi        # Power menu style
├── scripts/
│   ├── record-fullscreen.sh  # Fullscreen recording
│   ├── record-region.sh      # Region recording
│   ├── recording-indicator.sh # Waybar recording icon
│   ├── media.sh              # Media player controls
│   ├── power-profile.sh      # Power profile display
│   ├── power-profile-switch.sh # Power profile toggle
│   └── screenshot.sh         # Screenshot utility
├── swaync/
│   ├── config.json           # Notification center config
│   └── style.css             # Notification styles
├── waybar/
│   ├── config.jsonc          # Waybar module configuration
│   └── style.css             # Waybar styling
└── wallust/
    └── templates/            # Jinja2 templates (26 files)
```

## Hyprland

Hyprland configuration is split into modular Lua files for maintainability:

- `hypr/keybinds.lua` — All keyboard shortcuts
- `hypr/rules.lua` — Per-window rules (floating, workspace assignments, opacity)
- `hypr/appearance.lua` — Blur, animations, gaps, border settings
- `hypr/monitors.lua` — Display resolution, refresh rate, orientation

## Waybar

Waybar modules are configured in `waybar/config.jsonc` with these intervals:

| Module | Interval | Notes |
|--------|----------|-------|
| Workspaces | 3s | Uses `hyprctl workspaces -j` |
| CPU | 5s | Lightweight polling |
| Memory | 10s | RAM usage display |
| Network | 10s | Wi-Fi status |
| Recording | 10s | Blinks `` when active |
| Clock | 30s | Date and time |
| Power profiles | 30s | UPower D-Bus |
| Brightness | 5s | Backlight control |
| Notifications | 10s | SwayNC integration |

## Scripts

All scripts are in `scripts/` and follow these conventions:

- **Debounce mechanism** — Atomic `mkdir` to prevent double-firing (Hyprland sometimes fires keybinds twice)
- **Cross-type guards** — `pgrep -x wf-recorder` prevents overlapping recording types
- **Foreground execution** — Scripts run in foreground (no `&`/`wait`)
- **Notifications** — All actions send desktop notifications
