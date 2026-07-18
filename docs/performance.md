# Performance Optimization

bitzdots is designed for low-end hardware. This guide explains the optimizations and shows how to push further.

## Current Baseline

| Metric | Value |
|--------|-------|
| **Idle RAM (full stack)** | ~250-300MB |
| **Waybar CPU** | ~3.5% idle |
| **Hyprland RAM** | ~170MB |
| **swaync RAM** | ~85MB |
| **waybar RAM** | ~60MB |

## Per-Component Optimization

### Waybar Polling Intervals

All intervals are tuned to balance responsiveness and CPU usage:

| Module | Current Interval | CPU Impact |
|--------|-----------------|------------|
| Workspaces | 3s | Low (uses `hyprctl workspaces -j`, not clients) |
| Recording | 10s | Negligible |
| Network | 10s | Low |
| Clock | 30s | Negligible |
| CPU | 5s | Low (reads /proc/stat) |
| Memory | 10s | Negligible |
| Power Profiles | 30s | Negligible (D-Bus, no hanging) |
| Brightness | 5s | Low (timeout 2s on brightnessctl) |
| Notification | 10s | Negligible |
| Media | on-event | Only updates on player change |

**To reduce CPU further**, increase intervals in `waybar/config.jsonc`:
```jsonc
"custom/workspaces": { "interval": 5 },  // was 3
"custom/brightness": { "interval": 10 }, // was 5
```

### Media Player (playerctl)

The media script kills stale `playerctl metadata --follow` processes on startup to prevent the well-known CPU leak where multiple instances accumulate.

**If you don't use media controls**, remove `custom/media` from `modules-left` in waybar config.

### Power Profiles

Uses `busctl` directly on the UPower D-Bus interface instead of `powerprofilesctl`. The latter is known to randomly hang at 100% CPU when querying profiles. The D-Bus approach is instant and has zero CPU overhead.

### Blur & Visual Effects

Configurable in `hypr/appearance.lua`:

```lua
blur = {
    enabled = true,   -- set false to save ~20-40MB GPU memory
    size = 5,         -- lower = less memory
    passes = 1,       -- lower = less GPU work
}
```

**For maximum performance:**
```lua
blur = { enabled = false }
shadow = { enabled = false }
```

### SwayNC

Notification center RAM usage is ~85MB, largely from album art caching in the MPRIS widget.

Optimization available in `swaync/config.json`:

```jsonc
"mpris": {
    "show-album-art": "notification",  // "always" shows art in control center
    "image-size": 48                    // lower = less memory (default 64)
}
```

### Runcat (Python)

The `custom/runcat` module uses a Python script with pyjson5 dependency (~23MB RSS for the Python process).

**To disable:** Remove `custom/runcat` from `modules-left` in waybar config.

## Aggressive Low-End Profile

For systems with <2GB RAM or single-core CPUs:

1. **Disable blur** in `hypr/appearance.lua`:
   ```lua
   blur = { enabled = false }
   ```

2. **Remove runcat** from waybar modules

3. **Increase all polling intervals** in waybar config by 2-3x

4. **Remove album art** from swaync:
   ```jsonc
   "show-album-art": "never"
   ```

5. **Disable shadows** in Hyprland:
   ```lua
   shadow = { enabled = false }
   ```

6. **Use a lighter terminal** than kitty (e.g., foot or wezterm) — kitty uses ~200MB per window

7. **Disable animations** in `hypr/animations.lua`:
   ```lua
   hl.config({ animations = { enabled = false } })
   ```

## CPU Optimization

### Process Management

- **Wallpaper cache daemon** runs at Nice=19 (lowest priority), IO scheduling class=idle
- **All waybar scripts** are shell-based (no heavy interpreters except runcat's Python)
- **`playerctl metadata --follow`** leak prevention via pkill on media.sh startup
- **`workspaces.sh`** uses `hyprctl workspaces -j` instead of the heavier `hyprctl clients -j`

### Active CPU Reduction Tips

```bash
# Check current CPU usage by component
ps aux --sort=-%cpu | head -10

# Find and kill stale playerctl processes
ps aux | grep playerctl

# Check if powerprofilesctl is hanging
pgrep -a powerprofilesctl
```

## Memory Optimization

### Active Memory Reduction Tips

```bash
# Check current RAM usage
free -h

# Per-process memory
ps aux --sort=-%mem | head -15

# SwayNC memory breakdown
pmap $(pgrep -x swaync) | tail -5
```

### Swap Recommendations

On low-RAM systems (<2GB):

```bash
# Increase swap for safety
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
```

## Benchmarking

```bash
# Measure full stack idle memory
free -h

# Measure per-component memory
for p in Hyprland swaync waybar kitty; do
  ps -o rss,comm -C "$p" | tail -1
done

# Measure CPU over 30 seconds
top -b -n 30 -d 1 | grep -E 'Hyprland|waybar|swaync'
```
