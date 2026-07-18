# Frequently Asked Questions

## General

### What makes bitzdots different from other Hyprland dotfiles?

- **Low-end first** — Every component is optimized for minimal CPU and RAM usage
- **Full-stack auto-theming** — 26 Jinja2 templates propagate wallpaper colors to 20+ components
- **Event-driven cache daemon** — Wallpaper cache pre-generates in background so switching is instant
- **Safe by design** — Every theme generation backs up files and restores on failure
- **No bloat** — Every script and dependency earns its place

### What hardware does it support?

Any system that runs Hyprland. Optimized for low-end devices with 2-4GB RAM. The full desktop stack (Hyprland + waybar + swaync) idles under 300MB.

### Which distros are supported?

Arch Linux (including Arch-based), Fedora, Debian/Ubuntu, and NixOS. The installer auto-detects your distro.

### Do I need a GPU?

Hyprland requires a GPU with basic Vulkan support. Most integrated GPUs from 2012+ work.

## Installation

### The installer fails with "distro not supported"

The installer supports Arch, Fedora, Debian/Ubuntu, and NixOS. For other distros:

1. Install the packages manually (see [Installation](installation.md))
2. Link the config files manually

### Do I need to install packages manually?

No — use `./install.sh --with-deps` to auto-install everything. Without the flag, only configs are linked.

### I already have some of these tools configured

The installer creates symlinks. Your existing configs won't be touched unless they share the same filename.

## Theming

### Theme doesn't update after changing wallpaper

```bash
# Manually run theming
wallust run ~/.cache/current_wallpaper.png --config-dir ~/.config/wallust
~/.config/wallust/reload-theme.sh
```

### Colors look wrong on my wallpaper

Some images give poor Kmeans extraction. Try:
- Use a photo with more color variety
- Convert to PNG
- Manually adjust generated configs

The cache daemon has a 24-hour cooldown for problematic images.

### Qt/KDE apps aren't themed

```bash
# Verify correct package (NOT regular qt6ct):
paru -S qt6ct-kde   # Arch

# Check config:
cat ~/.config/qt6ct/qt6ct.conf  # Should have custom_palette=true
cat ~/.config/kdeglobals        # Should have [KDE] widgetStyle=qt6ct-style

# Verify environment:
echo $QT_STYLE_OVERRIDE         # Should be "breeze"
echo $QT_QPA_PLATFORMTHEME      # Should be "qt6ct"
```

## Waybar

### Waybar is not showing

```bash
# Start it manually
waybar &

# Check for errors
journalctl --user -u waybar -f
```

### A waybar module shows no output

Check the script runs independently:
```bash
~/.config/waybar/scripts/workspaces.sh
```

Common issues:
- Script not executable: `chmod +x script.sh`
- Missing dependency: check the script's requirements
- Poll interval too long: reduce `interval` in config.jsonc

### Media module shows "No player"

A media player must be running and exposing MPRIS controls:
- Spotify, Firefox (YouTube), VLC, etc.
- Check with `playerctl -l`

### Workspace module shows wrong workspaces

The workspace script uses `hyprctl workspaces -j`. Verify:
```bash
hyprctl workspaces
```

## Screenshots & Recording

### Screenshot saves but isn't in clipboard

Both Print and SUPER+SHIFT+S save to file AND copy to clipboard via `wl-copy`. If clipboard is empty:
- Ensure `wl-clipboard` is installed
- Try pasting with Ctrl+V or middle-click

### Screen recording doesn't include audio

Ensure `wf-recorder` is installed with pulse support:
```bash
# Arch
sudo pacman -S wf-recorder

# Check audio source
pactl list short sources
```

## Performance

### CPU usage is high

Check for common issues:
```bash
# Stale playerctl processes
pkill -f "playerctl metadata --follow"

# Check powerprofilesctl (should not be running — uses busctl instead)
pgrep powerprofilesctl

# View CPU by process
ps aux --sort=-%cpu | head -10
```

### RAM usage is higher than expected

```bash
# Check per-process memory
ps aux --sort=-%mem | head -15

# Common memory hogs
# - kitty: ~200MB per window (GPU-accelerated)
# - Browser: 200MB+ per process
# - swaync: ~85MB (album art caching)
```

### Waybar uses high CPU

```bash
# Check polling intervals (see performance.md)
cat ~/.config/waybar/config.jsonc | grep interval

# Most common culprit: workspaces.sh at high frequency
# Current: 3s — increase to 5s or 10s
```

## Cache Daemon

### Daemon status check

```bash
systemctl --user status wallust-cache-daemon.service
journalctl --user -u wallust-cache-daemon.service -f
```

### Daemon uses high CPU

The daemon runs at Nice=19 (lowest priority). If it uses CPU:
- It's actively processing wallpapers (normal during initial cache)
- After initial cache, it sleeps waiting for inotify events
- Check logs: `journalctl --user -u wallust-cache-daemon.service`

### Wallpaper palette generation fails

Logs show failures:
```bash
journalctl --user -u wallust-cache-daemon.service | grep -i "fail\|error"
```

Common causes:
- Image format not supported by wallust
- Image file is corrupted
- 24-hour cooldown active from previous failure

## General Troubleshooting

### SwayNC not showing notifications

```bash
# Restart swaync
swaync-client --reload-css
swaync-client -R  # Reload config
swaync-client -t  # Toggle panel

# Or fully restart
pkill swaync && swaync &
```

### Rofi not themed

Ensure `theme-generated.rasi` exists:
```bash
ls -la ~/.config/rofi/theme-generated.rasi
# If missing, regenerate theme:
wallust run ~/.cache/current_wallpaper.png --config-dir ~/.config/wallust
```

### Inconsistencies after theme change

```bash
# Full theme refresh
wallust run ~/.cache/current_wallpaper.png --config-dir ~/.config/wallust
~/.config/wallust/reload-theme.sh
pkill -x waybar && waybar &
```

### My changes keep getting overwritten

Configs marked "DO NOT EDIT" are auto-generated by wallust on every theme change. To make permanent changes:
- Edit the Jinja2 templates in `~/.config/wallust/templates/`
- Re-run wallust to apply
- See [Customization](customization.md)
