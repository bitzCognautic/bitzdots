# Installation

bitzdots supports Arch Linux, Fedora, Debian/Ubuntu, and NixOS. Choose your method below.

## Automated Install (Recommended)

```bash
git clone https://github.com/bitzCognautic/dots.git ~/.config/bitzdots
cd ~/.config/bitzdots
chmod +x install.sh

# Install configs only (no system packages):
./install.sh

# Install configs + system packages:
./install.sh --with-deps
```

The installer auto-detects your distro and installs the appropriate packages.

## Manual Install

### 1. Install Packages

Choose your distro:

<details>
<summary><b>Arch Linux</b></summary>

```bash
# Official repos
sudo pacman -S waybar swaync rofi kitty cava awww hyprpicker wl-clipboard \
  playerctl pavucontrol polkit-kde-agent grim slurp cliphist hyprlock \
  ffmpeg impala bluetui btop pulsemixer wf-recorder python breeze \
  inotify-tools imagemagick fastfetch fish power-profiles-daemon

# AUR (using paru or yay)
paru -S wallust qt6ct-kde ttf-jetbrains-mono-nerd
```
</details>

<details>
<summary><b>Fedora</b></summary>

```bash
sudo dnf install waybar swaync wlogout rofi kitty cava awww hyprpicker \
  wl-clipboard playerctl pavucontrol polkit-kde-agent grim slurp \
  cliphist hyprlock ffmpeg inotify-tools ImageMagick fastfetch fish \
  power-profiles-daemon

cargo install wallust
```
</details>

<details>
<summary><b>Debian/Ubuntu</b></summary>

```bash
sudo apt install waybar swaync wlogout rofi kitty cava awww hyprpicker \
  wl-clipboard playerctl pavucontrol polkit-kde-agent grim slurp \
  cliphist hyprlock ffmpeg inotify-tools imagemagick fastfetch fish

cargo install wallust
```
</details>

<details>
<summary><b>NixOS</b></summary>

```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    waybar swaync wlogout rofi kitty cava hyprpicker
    wl-clipboard playerctl pavucontrol polkit-kde-agent
    grim slurp cliphist hyprlock ffmpeg btop 
    inotify-tools imagemagick fastfetch fish
    wallust python3
  ];
}
```
</details>

### 2. Link Configuration Files

```bash
DOTFILES_DIR="$HOME/.config/bitzdots"
CONFIG_DIR="$HOME/.config"

# Hyprland
for f in "$DOTFILES_DIR/hypr"/*.lua; do
  ln -sf "$f" "$CONFIG_DIR/hypr/$(basename "$f")"
done

# Waybar
ln -sf "$DOTFILES_DIR/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc"
ln -sf "$DOTFILES_DIR/waybar/style.css" "$CONFIG_DIR/waybar/style.css"
for s in "$DOTFILES_DIR/waybar/scripts"/*.sh; do
  ln -sf "$s" "$CONFIG_DIR/waybar/scripts/$(basename "$s")"
done

# Rofi
ln -sf "$DOTFILES_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi/config.rasi"
ln -sf "$DOTFILES_DIR/rofi/theme-generated.rasi" "$CONFIG_DIR/rofi/theme-generated.rasi"
for d in themes colors scripts launchers icons; do
  mkdir -p "$CONFIG_DIR/rofi/$d"
  for f in "$DOTFILES_DIR/rofi/$d"/*; do
    ln -sf "$f" "$CONFIG_DIR/rofi/$d/$(basename "$f")"
  done
done

# SwayNC
ln -sf "$DOTFILES_DIR/swaync/config.json" "$CONFIG_DIR/swaync/config.json"
ln -sf "$DOTFILES_DIR/swaync/style.css" "$CONFIG_DIR/swaync/style.css"

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

# Wallust
ln -sf "$DOTFILES_DIR/wallust/wallust.toml" "$CONFIG_DIR/wallust/wallust.toml"
for t in "$DOTFILES_DIR/wallust/templates"/*; do
  ln -sf "$t" "$CONFIG_DIR/wallust/templates/"
done

# Scripts
for s in "$DOTFILES_DIR/scripts"/*.sh; do
  ln -sf "$s" "$CONFIG_DIR/wallust/$(basename "$s")"
done

# GTK/Qt
ln -sf "$DOTFILES_DIR/gtk/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
ln -sf "$DOTFILES_DIR/gtk/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0/settings.ini"
mkdir -p "$CONFIG_DIR/environment.d"
ln -sf "$DOTFILES_DIR/environment.d/qt.conf" "$CONFIG_DIR/environment.d/qt.conf"

# Fish
mkdir -p "$CONFIG_DIR/fish"
ln -sf "$DOTFILES_DIR/fish/config.fish" "$CONFIG_DIR/fish/config.fish"

# Fastfetch
mkdir -p "$CONFIG_DIR/fastfetch"
ln -sf "$DOTFILES_DIR/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"
ln -sf "$DOTFILES_DIR/fastfetch/bitz.txt" "$CONFIG_DIR/fastfetch/bitz.txt"
```

### 3. Systemd Service

```bash
mkdir -p "$CONFIG_DIR/systemd/user"
cp "$DOTFILES_DIR/systemd/user/wallust-cache-daemon.service" \
   "$CONFIG_DIR/systemd/user/wallust-cache-daemon.service"
systemctl --user daemon-reload
systemctl --user enable --now wallust-cache-daemon.service
```

### 4. Install Font

```bash
# Arch (AUR)
paru -S ttf-jetbrains-mono-nerd

# Or download manually from https://www.nerdfonts.com/
```

### 5. Generate Initial Theme

```bash
wallust run ~/Pictures/Wallpapers/your-wallpaper.jpg \
  --config-dir ~/.config/wallust
```

### 6. Set Fish as Default Shell (Optional)

```bash
chsh -s $(which fish)
```

Log out and back in for the change to take effect.

## Post-Installation Checklist

- [ ] Waybar is visible at the top of the screen
- [ ] Pressing `SUPER + T` opens kitty
- [ ] Pressing `SUPER + Space` opens rofi launcher
- [ ] Pressing `Print` saves a screenshot
- [ ] `SUPER + SHIFT + W` opens the wallpaper picker
- [ ] Changing the wallpaper updates all colors
- [ ] Notifications appear and the control center opens with `SUPER + N`
- [ ] The wallpaper cache daemon is running: `systemctl --user status wallust-cache-daemon.service`

## Troubleshooting

See the [FAQ](faq.md) for common issues.
