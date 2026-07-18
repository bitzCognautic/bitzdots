# Installation

## Prerequisites

- Arch Linux (or any Arch-based distribution)
- Hyprland (window manager)
- `git` installed

## Automated Install

Clone the repository and run the install script:

```bash
git clone https://github.com/bitzCognautic/bitzdots.git ~/.config
chmod +x ~/.config/scripts/install.sh
~/.config/scripts/install.sh
```

The install script will:

1. Install required packages (fish, fastfetch, power-profiles-daemon, etc.)
2. Set fish as the default shell (`chsh -s $(which fish)`)
3. Create screenshot directories
4. Configure all dotfiles

## Manual Install

### 1. Install Dependencies

**Core:**
- `hyprland` — Window manager
- `waybar` — Status bar
- `rofi-lbonn-wayland` — Launcher
- `swaync` — Notification center
- `wallust` — Color generation from wallpapers
- `fish` — Shell
- `fastfetch` — System info

**Scripts:**
- `wf-recorder` — Screen recording
- `slurp` — Region selection
- `wl-clipboard` — Clipboard (`wl-copy`, `wl-paste`)
- `pulseaudio-utils` — Audio control (`pactl`)
- `playerctl` — Media player control
- `grim` — Screenshots
- `swaybg` or `hyprpaper` — Wallpaper

**Optional:**
- `power-profiles-daemon` — Power profiles

### 2. Clone Configs

```bash
git clone https://github.com/bitzCognautic/bitzdots.git ~/.config/bitzdots
ln -sf ~/.config/bitzdots/* ~/.config/
```

### 3. Set Fish as Default Shell

```bash
chsh -s $(which fish)
```

### 4. Create Screenshot Directories

```bash
mkdir -p ~/Pictures/Screenshots/{Fullscreen,Freeform}
mkdir -p ~/Videos/Recordings/{Fullscreen,Region}
```

### 5. Reboot

Log out and back in, or reboot for all changes to take effect.

## Post-Install

1. Set a wallpaper with `wallust run /path/to/wallpaper.jpg` to generate color schemes
2. Check that all waybar modules are loading correctly
3. Customize keybindings in `hypr/keybinds.lua`
