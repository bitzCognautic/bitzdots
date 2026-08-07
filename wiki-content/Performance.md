# Performance

bitzdots is specifically optimized for low-end machines. Here's the performance tuning guide.

## Benchmarks

| Metric | Value |
|--------|-------|
| Idle RAM (full stack) | ~250-300MB |
| Hyprland RAM | ~170MB |
| swaync RAM | ~85MB |
| Waybar RAM | ~60MB |
| Waybar CPU | ~3.5% idle |
| Polling intervals | max 30s |

## Optimizations Applied

### CPU

- **Polling intervals capped at 30s** — No sub-second polling in any module
- **Workspaces use `hyprctl workspaces -j`** instead of `hyprctl clients -j` (lighter query)
- **No `playerctl metadata --follow` leaks** — Killed on media.sh startup
- **`busctl` over `powerprofilesctl`** — The latter can hang at 100% CPU
- **Recording indicator uses `pgrep`** — No file watchers or continuous processes
- **Cache daemon runs at Nice=19, idle IO** — Never competes with foreground apps

### RAM

- **SwayNC** — `show-album-art` kept minimal to reduce album-art caching memory
- **Hyprland blur** — Small blur size (5)
- **Minimal background services** — No unnecessary daemons

### GPU

- **Blur/shadows configurable** — Disable for maximum performance (see below)
- **No excessive animations** — Minimal fade animations only

## Aggressive Low-End Profile

For systems with <2GB RAM or single-core CPUs:

1. **Disable blur & shadows** in `hypr/appearance.lua`:
   ```lua
   blur = { enabled = false }
   shadow = { enabled = false }
   ```

2. **Remove runcat** from waybar `modules-left` (Python process ~23MB)

3. **Increase polling intervals** in `waybar/config.jsonc` by 2-3x

4. **Remove album art** from swaync notifications

5. **Disable animations** in `hypr/animations.lua`:
   ```lua
   animations = { enabled = false }
   ```

## Waybar Polling Intervals

| Module | Current Interval | CPU Impact |
|--------|-----------------|------------|
| Workspaces | 2s | Low (uses `hyprctl workspaces -j`) |
| Recording | 10s | Negligible |
| Network | 3s | Low |
| Clock | 30s | Negligible |
| CPU | 5s | Low (reads /proc/stat) |
| Memory | 10s | Negligible |
| Power Profiles | 5s | Negligible (D-Bus) |
| Brightness | 5s | Low (timeout 2s on brightnessctl) |
| Notification | 10s | Negligible |
| Media | on-event | Only updates on player change |

**To reduce CPU further**, increase intervals in `waybar/config.jsonc`:
```jsonc
"custom/workspaces": { "interval": 5 },  // was 2
"custom/brightness": { "interval": 10 }, // was 5
```

## Additional Tuning Tips

### Kernel Parameters

Add to `/etc/sysctl.d/99-performance.conf`:

```
vm.swappiness=10
vm.vfs_cache_pressure=50
kernel.numa_balancing=0
```

### CPU Governor

```bash
sudo cpupower frequency-set -g performance
```

Or use `power-profiles-daemon` with the waybar module to toggle on the fly (`SUPER` + waybar power-profile click).

### Memory Optimization

```bash
# Check current RAM usage
free -h

# Per-process memory
ps aux --sort=-%mem | head -15
```

On low-RAM systems (<2GB), add swap:
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
```

### Benchmarking

```bash
# Measure full stack idle memory
free -h

# Measure per-component memory
for p in Hyprland swaync waybar kitty; do
  ps -o rss,comm -C "$p" | tail -1
done
```
