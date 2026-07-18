# Performance

bitzdots is specifically optimized for low-end machines. Here's the performance tuning guide.

## Benchmarks

| Metric | Default Hyprland | bitzdots optimized |
|--------|-----------------|-------------------|
| CPU idle | ~8-12% | ~3.5% |
| RAM idle | ~700-900MB | ~500-600MB |
| Waybar CPU | ~6-8% | ~3.5% |
| SwayNC RAM | ~80MB | ~45MB |

## Optimizations Applied

### CPU

- **Polling intervals capped at 30s** — No sub-second polling in any module
- **Workspaces use `hyprctl workspaces -j`** instead of `hyprctl clients -j` (lighter query)
- **No `playerctl metadata --follow` leaks** — Killed on media.sh startup
- **`busctl` over `powerprofilesctl`** — The latter can hang at 100% CPU
- **Recording indicator uses `pgrep`** — No file watchers or continuous processes

### RAM

- **SwayNC** — `show-album-art: "notification"` (was `"always"`), `image-size: 48` (was 64)
- **Hyprland blur** — `blur.size = 5` (was 10)
- **Minimal background services** — No unnecessary daemons

### GPU

- **Blur disabled on low-end GPUs** — Configurable in `hypr/appearance.lua`
- **No excessive animations** — Minimal fade animations only
- **No shadows on floating windows** — Hardware compositing-friendly

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

Or use `power-profiles-daemon` with the waybar module to toggle on the fly.

### Disable Compositing

For gaming or fullscreen apps, Hyprland handles this automatically with the fullscreen rule, but you can also bind:

```bash
SUPER+F # Toggle fullscreen (disables compositing)
```

### Reduce Animation

In `hypr/appearance.lua`:

```lua
-- For max performance:
animations = {
    enabled = false
}

-- For balanced:
animations = {
    enabled = true,
    bezier = "easeOutQuint",
    animation = "fade",
    duration = 0.2
}
```
