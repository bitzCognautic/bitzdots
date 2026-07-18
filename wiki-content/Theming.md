# Theming

## Auto-Coloring Pipeline

bitzdots uses **wallust** to generate a complete color scheme from any wallpaper. The theming pipeline is fully automatic.

### How It Works

```
Select wallpaper
      ↓
wallust run wallpaper.jpg
      ↓
Generates 16-color palette
      ↓
26 Jinja2 templates processed
      ↓
Templates written to:
  ├── waybar/style.css
  ├── swaync/style.css
  ├── rofi/*.rasi
  ├── hypr/appearance.lua
  └── 22 other config files
```

### 26 Templates

The `wallust/templates/` directory contains Jinja2 templates for every themed component:

| # | Template | Output | Purpose |
|---|----------|--------|---------|
| 1 | `waybar-style` | `waybar/style.css` | Status bar colors |
| 2 | `swaync-style` | `swaync/style.css` | Notification center |
| 3-8 | `rofi-*` | `rofi/*.rasi` | Launcher styles |
| 9 | `hypr-appearance` | `hypr/appearance.lua` | Window decorations |
| 10-26 | Various | Various | Other themed files |

### Changing Theme

Simply run:

```bash
wallust run /path/to/new-wallpaper.jpg
```

All 26 templates are re-processed automatically. Changes take effect immediately for most components (some may need a reload).

### Templates

Templates use wallust's Jinja2 syntax:

```jinja
{{color0}}   ← Background
{{color1}}   ← Red/shadow
{{color2}}   ← Green
{{color3}}   ← Yellow
{{color4}}   ← Blue
{{color5}}   ← Magenta
{{color6}}   ← Cyan
{{color7}}   ← Foreground
{{color8-15}} ← Light variants
```

### Wallpapers

Place wallpapers in `~/Pictures/Wallpapers/`. The system uses `swaybg` or `hyprpaper` to display the wallpaper.

## Manual Override

You can edit `wallust/templates/` to customize color mappings. After changing a template, re-run:

```bash
wallust run ~/Pictures/Wallpapers/current.jpg
```
