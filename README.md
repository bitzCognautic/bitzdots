# bitzdots

Hyprland dotfiles with automatic wallust color theming. Every component — waybar, rofi, kitty, swaync, wlogout, cava, even Qt/KDE apps — picks up colors from your wallpaper automatically.

## Requirements

- **Hyprland** (Wayland compositor)
- **wallust** — color palette generator (AUR: `wallust`, or `cargo install wallust`)
- **inotify-tools** — for the cache daemon
- **Nerd Font** — icons in waybar/rofi (JetBrainsMono Nerd Font recommended)
- **Optional but recommended:**
  - `awww` — animated wallpaper transitions
  - `mpvpaper` — live video wallpapers
  - `qt6ct-kde` — Qt/KDE app theming (AUR)
  - `cliphist` — clipboard manager
  - `hyprlock` — screen locker
  - `ffmpeg` — video frame extraction for live wallpapers
  - `imagemagick` — thumbnail generation

## Quick Install (Automated)

```bash
git clone https://github.com/bitzCognautic/dots.git ~/.config/bitzdots
cd ~/.config/bitzdots
chmod +x install.sh

# Install configs only (recommended first run):
./install.sh

# Install configs + system packages:
./install.sh --with-deps
```

The installer will:
1. Link all config files to `~/.config/`
2. Install and enable the wallpaper cache systemd service
3. Generate an initial color theme from your first wallpaper
4. Set up the wallpaper picker keybind

## Manual Install (Step by Step)

### 1. Install Packages

**Arch Linux:**
```bash
sudo pacman -S waybar swaync rofi kitty cava awww hyprpicker wl-clipboard \
  playerctl pavucontrol polkit-kde-agent grim slurp cliphist hyprlock \
  ffmpeg impala bluetui btop pulsemixer wf-recorder python breeze \
  inotify-tools imagemagick

# AUR:
paru -S wallust qt6ct-kde ttf-jetbrains-mono-nerd
```

**Fedora:**
```bash
sudo dnf install waybar swaync wlogout rofi kitty cava awww hyprpicker \
  wl-clipboard playerctl pavucontrol polkit-kde-agent grim slurp \
  cliphist hyprlock ffmpeg inotify-tools ImageMagick

cargo install wallust
```

**Debian/Ubuntu:**
```bash
sudo apt install waybar swaync wlogout rofi kitty cava awww hyprpicker \
  wl-clipboard playerctl pavucontrol polkit-kde-agent grim slurp \
  cliphist hyprlock ffmpeg inotify-tools imagemagick

cargo install wallust
```

### 2. Link Configs

```bash
DOTFILES_DIR="$HOME/your/clone/path"
CONFIG_DIR="$HOME/.config"

# Hyprland
ln -sf "$DOTFILES_DIR/hypr"/*.lua "$CONFIG_DIR/hypr/"

# Waybar
ln -sf "$DOTFILES_DIR/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc"
ln -sf "$DOTFILES_DIR/waybar/style.css" "$CONFIG_DIR/waybar/style.css"
ln -sf "$DOTFILES_DIR/waybar/colors/teto.css" "$CONFIG_DIR/waybar/colors/teto.css"
for s in "$DOTFILES_DIR/waybar/scripts"/*.sh; do
  ln -sf "$s" "$CONFIG_DIR/waybar/scripts/$(basename "$s")"
done

# SwayNC
ln -sf "$DOTFILES_DIR/swaync/config.json" "$CONFIG_DIR/swaync/config.json"
ln -sf "$DOTFILES_DIR/swaync/style.css" "$CONFIG_DIR/swaync/style.css"
ln -sf "$DOTFILES_DIR/swaync/media-swaync.sh" "$CONFIG_DIR/swaync/media-swaync.sh"

# Rofi
ln -sf "$DOTFILES_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi/config.rasi"
for f in "$DOTFILES_DIR/rofi/colors"/*.rasi; do
  ln -sf "$f" "$CONFIG_DIR/rofi/colors/$(basename "$f")"
done
for f in "$DOTFILES_DIR/rofi/themes"/*.rasi; do
  ln -sf "$f" "$CONFIG_DIR/rofi/themes/$(basename "$f")"
done
for s in "$DOTFILES_DIR/rofi/scripts"/*.sh; do
  ln -sf "$s" "$CONFIG_DIR/rofi/scripts/$(basename "$s")"
done

# Kitty
ln -sf "$DOTFILES_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"

# Cava
ln -sf "$DOTFILES_DIR/cava/config" "$CONFIG_DIR/cava/config"
for f in "$DOTFILES_DIR/cava/shaders"/*; do
  ln -sf "$f" "$CONFIG_DIR/cava/shaders/$(basename "$f")"
done

# Wlogout
ln -sf "$DOTFILES_DIR/wlogout/style.css" "$CONFIG_DIR/wlogout/style.css"
ln -sf "$DOTFILES_DIR/wlogout/layout" "$CONFIG_DIR/wlogout/layout"
for f in "$DOTFILES_DIR/wlogout/assets"/*; do
  ln -sf "$f" "$CONFIG_DIR/wlogout/assets/$(basename "$f")"
done

# Wallust (theming engine)
ln -sf "$DOTFILES_DIR/wallust/wallust.toml" "$CONFIG_DIR/wallust/wallust.toml"
for t in "$DOTFILES_DIR/wallust/templates"/*; do
  ln -sf "$t" "$CONFIG_DIR/wallust/templates/"
done

# Scripts
for s in "$DOTFILES_DIR/scripts"/*.sh; do
  ln -sf "$s" "$CONFIG_DIR/wallust/$(basename "$s")"
done

# GTK/Qt theme
ln -sf "$DOTFILES_DIR/gtk/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
ln -sf "$DOTFILES_DIR/gtk/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0/settings.ini"
ln -sf "$DOTFILES_DIR/environment.d/qt.conf" "$CONFIG_DIR/environment.d/qt.conf"

# Systemd service (wallpaper cache daemon)
mkdir -p "$CONFIG_DIR/systemd/user"
cp "$DOTFILES_DIR/systemd/user/wallust-cache-daemon.service" \
   "$CONFIG_DIR/systemd/user/wallust-cache-daemon.service"
systemctl --user daemon-reload
systemctl --user enable --now wallust-cache-daemon.service
```

### 3. Install Nerd Font

```bash
# Arch (AUR)
paru -S ttf-jetbrains-mono-nerd

# Or download manually from https://www.nerdfonts.com/
```

### 4. Generate Initial Theme

```bash
wallust run ~/Pictures/Wallpapers/your-wallpaper.jpg \
  --config-dir ~/.config/wallust
```

### 5. Set Wallpaper

```bash
# Static with transition:
awww img ~/Pictures/Wallpapers/your-wallpaper.jpg

# Or via the picker:
~/.config/wallust/wallpaper-select.sh
```

## Directory Structure

```
~/.config/
├── hypr/              # Hyprland config (Lua)
│   ├── hyprland.lua   # Entry point, loads all modules
│   ├── keybinds.lua   # All keybindings
│   ├── appearance.lua # Blur, opacity, borders, shadows
│   ├── animations.lua # Window animations
│   ├── rules.lua      # Window rules (float, opacity, etc.)
│   ├── monitors.lua   # Monitor setup
│   ├── input.lua      # Keyboard, mouse, touchpad
│   ├── variables.lua  # Environment variables
│   └── autostart.lua  # Startup applications
│
├── waybar/            # Status bar
│   ├── config.jsonc   # Module layout
│   ├── style.css      # Styling (auto-generated by wallust)
│   ├── colors/        # Color scheme overrides
│   └── scripts/       # Custom modules (workspaces, media, system)
│
├── rofi/              # App launcher & menus
│   ├── config.rasi    # Main config
│   ├── themes/        # 24+ theme variants
│   ├── colors/        # 16 color schemes
│   ├── scripts/       # Clipboard, power menu, wallpaper
│   └── launchers/     # Launcher scripts
│
├── swaync/            # Notification center
│   ├── config.json
│   └── style.css      # (auto-generated by wallust)
│
├── wlogout/           # Logout screen
│   ├── layout
│   ├── style.css      # (auto-generated by wallust)
│   └── assets/        # SVG icons
│
├── kitty/             # Terminal
│   └── kitty.conf     # Colors auto-generated by wallust
│
├── cava/              # Audio visualizer
│   ├── config
│   └── shaders/       # GLSL shaders
│
├── wallust/           # Theming engine
│   ├── wallust.toml   # Template definitions
│   ├── templates/     # 26 Jinja2 templates
│   └── *.sh           # Theme scripts
│
├── qt6ct/             # Qt theme (KDE apps)
│   └── qt6ct.conf     # (auto-generated by wallust)
│
├── systemd/user/      # User systemd services
│   └── wallust-cache-daemon.service
│
└── gtk-3.0/           # GTK theme
    └── settings.ini
```

## Keybindings

| Key | Action |
|-----|--------|
| `SUPER + T` | Open terminal (kitty) |
| `SUPER + Q` | Close window |
| `SUPER + E` | Open file manager (dolphin) |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + W` | Open browser |
| `SUPER + L` | Lock screen |
| `SUPER + Space` | App launcher (rofi) |
| `SUPER + V` | Clipboard history |
| `SUPER + N` | Toggle notifications |
| `SUPER + P` | Power menu |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + SHIFT + S` | Selection screenshot |
| `SUPER + SHIFT + W` | Wallpaper picker |
| `SUPER + R` | Record fullscreen |
| `SUPER + SHIFT + R` | Record region |
| `SUPER + C` | Open VS Code |
| `SUPER + CTRL + C` | Color picker |
| `SUPER + H` / `SUPER + CTRL + F` | Toggle window float |
| `SUPER + CTRL + R` | Resize mode |
| `SUPER + CTRL + Q` | Exit Hyprland |

### Waybar Click Actions

| Module | Left Click | Right Click |
|--------|-----------|-------------|
| Media | Play/Pause | Stop |
| Network | WiFi TUI | — |
| Bluetooth | Bluetooth TUI | — |
| Notification | Toggle panel | Toggle DnD |
| Audio | Audio TUI | — |
| CPU | CPU TUI | — |
| Memory/Power | btop | — |
| Power Profile | Cycle profile | — |
| Power | Power menu | — |

## How Theming Works

1. **wallust** extracts a 16-color palette from your wallpaper (Kmeans algorithm)
2. Jinja2 templates in `wallust/templates/` render the colors into config files for every component
3. `reload-theme.sh` notifies running apps of the color change
4. The cache daemon (`wallust-cache-daemon.service`) watches your wallpaper folders with `inotify` and pre-generates palettes so switching is instant

### Wallpaper States (Waybar Icons)

| Icon | State |
|------|-------|
| 󰤨 (wifi full) | Connected to WiFi |
| 󰈀 (ethernet) | Connected via ethernet |
| 󰤮 (wifi slash) | WiFi off or disconnected |
| 󰂲 (bluetooth) | Bluetooth connected |
| 󰂱 (bluetooth dim) | Bluetooth on, no connection |
| 󰂯 (bluetooth dimmer) | Bluetooth disabled |

## Wallpaper Management

**Add static wallpapers:**
```bash
cp your-image.jpg ~/Pictures/Wallpapers/
# Daemon auto-generates palette in background
```

**Add live wallpapers:**
```bash
cp your-video.mp4 ~/Pictures/Wallpapers/live/
```

**Select wallpaper:**
```bash
# Via keybind:
SUPER + SHIFT + W

# Or command line:
~/.config/wallust/wallpaper-select.sh
~/.config/wallust/wallpaper-select.sh /path/to/image.jpg
```

**Manually regenerate theme:**
```bash
wallust run ~/Pictures/Wallpapers/image.jpg --config-dir ~/.config/wallust
~/.config/wallust/reload-theme.sh
```

## Customization

### Edit templates

Wallust templates are in `~/.config/wallust/templates/`. After editing:

```bash
# Regenerate theme to apply changes:
wallust run ~/.cache/current_wallpaper.png --config-dir ~/.config/wallust
```

### Change colors manually

Override any color by editing the generated config directly (reverted on next wallpaper change).

### Add new themed component

1. Create a Jinja2 template: `wallust/templates/myapp.conf.j2`
2. Add to `wallust.toml`:
   ```toml
   myapp.template = "myapp.conf.j2"
   myapp.target = "~/.config/myapp/config"
   ```
3. Add to `WALLUST_OUTPUTS` in `wallpaper-select.sh` and `wallust-cache-daemon.sh`
4. Run wallust to generate

## Troubleshooting

### Wallpaper palette generation fails

Some images cause wallust's Kmeans parser to hang. The daemon has a 30-second timeout and logs failures. Try a different image or convert to PNG.

```bash
journalctl --user -u wallust-cache-daemon.service
```

### Qt/KDE apps not themed

```bash
# Verify qt6ct-kde is installed (NOT regular qt6ct):
paru -S qt6ct-kde

# Check config:
cat ~/.config/qt6ct/qt6ct.conf  # Should have custom_palette=true
cat ~/.config/kdeglobals        # Should have [KDE] widgetStyle=qt6ct-style

# Environment must include:
export QT_STYLE_OVERRIDE=breeze
export QT_QPA_PLATFORMTHEME=qt6ct
```

### Waybar not updating after theme change

```bash
pkill -x waybar && waybar &
```

### Check daemon status

```bash
systemctl --user status wallust-cache-daemon.service
journalctl --user -u wallust-cache-daemon.service -f
```

## License

MIT
