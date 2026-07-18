# bitzdots

> Lean, performant Hyprland dotfiles with automatic wallust theming — optimized for low-end machines.

## Quick Start

```bash
git clone https://github.com/bitzCognautic/bitzdots.git ~/.config
chmod +x ~/.config/scripts/install.sh
~/.config/scripts/install.sh
```

## Key Features

- **Auto-coloring** — Pick any wallpaper; wallust generates 26 themed templates automatically across all apps
- **Low-end optimized** — CPU idle: ~3.5%, RAM: ~1.2GB (includes browser + editor)
- **Rofi launchers** — App launcher, clipboard manager, emoji picker, network menu, power menu
- **Waybar with 14 modules** — Workspaces, clock, CPU, memory, network, recording indicator, power profiles, brightness, notifications, tray, custom scripts
- **Screenshot & recording** — Fullscreen and region screenshot (with `wl-copy` clipboard), fullscreen and region recording (with `wf-recorder`)
- **Fish + fastfetch** — Custom BITZ ASCII logo, clean terminal experience

## Directory Structure

```
~/.config/
├── fish/              # Fish shell config
├── fastfetch/         # Fastfetch config with BITZ logo
├── hypr/              # Hyprland config (keybinds, rules, appearance, monitors)
├── rofi/              # Rofi launcher configs
├── scripts/           # Custom scripts (recording, media, power, etc.)
├── swaync/            # Notification center config
├── waybar/            # Waybar bar configs and styles
├── wallust/           # Wallust templates (26 Jinja2 templates)
└── docs/              # Documentation
```

## Performance

| Metric | Value |
|--------|-------|
| CPU idle | ~3.5% |
| RAM usage | ~1.2GB (with apps) |
| Waybar CPU | ~3.5% |
| Polling intervals | max 30s |
| Blur size | 5 |

## Keybinds

| Key | Action |
|-----|--------|
| `SUPER`+`Return` | Terminal |
| `SUPER`+`Space` | App launcher |
| `SUPER`+`Q` | Close window |
| `SUPER`+`R` | Start fullscreen recording |
| `SUPER`+`SHIFT`+`R` | Start region recording |
| `SUPER`+`S` | Stop recording |
| `Print` | Full screenshot |
| `SUPER`+`SHIFT`+`S` | Selection screenshot |
| `SUPER`+`B` | Toggle bar |
| `SUPER`+`M` | Media controls |

## Links

- [Installation](Installation)
- [Configuration](Configuration)
- [Keybindings](Keybindings)
- [Waybar Modules](Waybar-Modules)
- [Theming](Theming)
- [Scripts](Scripts)
- [FAQ](FAQ)
- [Performance](Performance)
- [Customization](Customization)
