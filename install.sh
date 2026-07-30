#!/bin/bash
# ============================================================
# bitzdots — Automated Installer with wallust theming
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
WALL_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[bitzdots]${NC} $1"; }
ok()   { echo -e "${GREEN}[  ok  ]${NC} $1"; }
warn() { echo -e "${YELLOW}[ warn ]${NC} $1"; }
fail() { echo -e "${RED}[ fail ]${NC} $1"; exit 1; }

detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif command -v nix-env &>/dev/null; then
        echo "nixos"
    else
        echo "unknown"
    fi
}

install_deps() {
    local distro
    distro=$(detect_distro)
    log "Detected distro: $distro"

    case "$distro" in
        arch)
            log "Installing packages (Arch)..."
            local repo_pkgs=(
                waybar swaync wlogout rofi kitty cava
                hyprpicker wl-clipboard playerctl pavucontrol
                polkit-kde-agent grim slurp cliphist hyprlock ffmpeg
                btop pulsemixer wf-recorder python
                power-profiles-daemon breeze inotify-tools fish fastfetch
                brightnessctl bluez bluez-utils libnotify networkmanager
                wireplumber pipewire-pulse curl jq imagemagick
                nautilus wofi papirus-icon-theme wallust bluetui
            )
    local missing=()
    sudo pacman -S --needed --noconfirm "${repo_pkgs[@]}" 2>&1 | \
        grep -o "target not found: [^']*" | cut -d' ' -f4 > /tmp/missing_pkgs.txt || true
    if [ -s /tmp/missing_pkgs.txt ]; then
        mapfile -t missing < /tmp/missing_pkgs.txt
    fi
    rm -f /tmp/missing_pkgs.txt
    missing+=(awww impala)

    if command -v paru &>/dev/null; then
        log "Installing via paru: ${missing[*]}"
        paru -S --needed --noconfirm "${missing[@]}" || true
    elif command -v yay &>/dev/null; then
        yay -S --needed --noconfirm "${missing[@]}" || true
    else
        warn "No AUR helper found. Install manually:"
        printf '  paru -S %s\n' "${missing[@]}"
    fi
            # Cargo fallback for wallust
            if ! command -v wallust &>/dev/null; then
                if command -v cargo &>/dev/null; then
                    warn "Installing wallust via cargo..."
                    cargo install wallust || true
                else
                    warn "wallust not installed — run: cargo install wallust"
                fi
            fi
            ;;
        fedora)
            log "Installing packages (Fedora)..."
            sudo dnf install -y \
                waybar swaync wlogout rofi kitty cava \
                awww hyprpicker wl-clipboard playerctl pavucontrol \
                polkit-kde-agent grim slurp cliphist hyprlock ffmpeg \
                inotify-tools fish fastfetch btop pulsemixer \
                wf-recorder python3 impala \
                brightnessctl bluez libnotify \
                NetworkManager wireplumber pipewire-pulseaudio \
                curl jq ImageMagick nautilus wofi papirus-icon-theme
            if ! command -v wallust &>/dev/null; then
                if command -v cargo &>/dev/null; then
                    cargo install wallust || true
                else
                    warn "wallust not installed — run: cargo install wallust"
                fi
            fi
            ;;
        debian)
            log "Installing packages (Debian/Ubuntu)..."
            sudo apt install -y \
                waybar swaync wlogout rofi kitty cava \
                awww hyprpicker wl-clipboard playerctl pavucontrol \
                polkit-kde-agent grim slurp cliphist hyprlock ffmpeg \
                inotify-tools fish fastfetch btop pulsemixer \
                wf-recorder python3 \
                brightnessctl bluez bluez-utils libnotify-bin \
                network-manager wireplumber pipewire-pulse \
                curl jq imagemagick nautilus wofi papirus-icon-theme
            if ! command -v wallust &>/dev/null; then
                if command -v cargo &>/dev/null; then
                    cargo install wallust || true
                else
                    warn "wallust not installed — run: cargo install wallust"
                fi
            fi
            ;;
        nixos)
            log "NixOS detected — add these to your configuration.nix:"
            echo "  services.awww.enable = true;"
            echo "  programs.waybar.enable = true;"
            echo "  programs.rofi.enable = true;"
            echo "  environment.systemPackages = with pkgs; ["
            echo "    wallust swaync wlogout kitty cava inotify-tools"
            echo "    hyprpicker wl-clipboard playerctl pavucontrol"
            echo "    polkit-kde-agent grim slurp cliphist hyprlock ffmpeg"
            echo "    fish fastfetch btop pulsemixer wf-recorder python3"
            echo "    brightnessctl bluez bluez-utils libnotify"
            echo "    networkmanager wireplumber pipewire-pulse"
            echo "    curl jq imagemagick nautilus wofi papirus-icon-theme"
            echo "  ];"
            echo "  services.bluetooth.enable = true;"
            ;;
        *)
            warn "Unknown distro. Please install manually:"
            echo "  - wallust (https://github.com/explosion-mental/wallust)"
            echo "  - waybar, swaync, wlogout, rofi, kitty, cava"
            echo "  - awww, hyprpicker, wl-clipboard, playerctl"
            echo "  - pavucontrol, polkit-kde-agent, grim, slurp, cliphist"
            echo "  - hyprlock, ffmpeg, inotify-tools"
            echo "  - fish, fastfetch, btop, pulsemixer, wf-recorder, python3"
            echo "  - brightnessctl, bluez, bluez-utils, libnotify"
            echo "  - networkmanager, wireplumber, pipewire-pulse, curl, jq"
            echo "  - imagemagick, nautilus, wofi, papirus-icon-theme"
            ;;
    esac
}

install_nerd_font() {
    if fc-list :family 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        ok "JetBrainsMono Nerd Font already installed"
        return
    fi

    log "Installing JetBrainsMono Nerd Font..."

    if command -v paru &>/dev/null; then
        paru -S --needed --noconfirm ttf-jetbrains-mono-nerd && return
    fi

    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm ttf-jetbrains-mono-nerd && return
    fi

    warn "No AUR helper found. Install manually: paru -S ttf-jetbrains-mono-nerd"
}

link_config() {
    local src="$1"
    local dest="$2"
    local name="$3"

    [ -e "$src" ] || return

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        warn "$name config exists at $dest — backing up to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    if [ -L "$dest" ]; then
        return
    fi

    ln -sf "$src" "$dest"
}

setup_wallpapers() {
    mkdir -p "$WALL_DIR" "$WALL_DIR/live"
    for f in "$DOTFILES_DIR/hypr/wallpapers"/* "$DOTFILES_DIR/Wallpapers"/*; do
        [ -f "$f" ] || continue
        cp -n "$f" "$WALL_DIR/" 2>/dev/null || true
    done
    ok "Wallpapers ready: $WALL_DIR/"
}

setup_cache() {
    mkdir -p "$CACHE_DIR"
}

setup_runcat() {
    local module_dir="$CONFIG_DIR/waybar/modules/runcat-text"
    [ -d "$DOTFILES_DIR/waybar/modules/runcat-text" ] || return

    mkdir -p "$module_dir"
    cp "$DOTFILES_DIR/waybar/modules/runcat-text"/* "$module_dir/"

    local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    mkdir -p "$font_dir"
    if [ -f "$module_dir/runcat.ttf" ] && ! fc-list :family 2>/dev/null | grep -qi "runcat"; then
        cp "$module_dir/runcat.ttf" "$font_dir/"
        fc-cache -f 2>/dev/null || true
    fi

    if [ ! -f "$module_dir/.venv/bin/python" ] && command -v python &>/dev/null; then
        python -m venv "$module_dir/.venv"
        "$module_dir/.venv/bin/pip" install -q "$module_dir/requirements.txt" 2>/dev/null || \
            "$module_dir/.venv/bin/pip" install -q pyjson5 2>/dev/null || true
    fi
    ok "runcat-text setup complete"
}

install_scripts() {
    local scripts_dir="$CONFIG_DIR/wallust"
    mkdir -p "$scripts_dir/templates"

    for s in reload-theme.sh wallpaper-select.sh cache-wallpapers.sh wallust-cache-daemon.sh record-fullscreen.sh record-region.sh recording-indicator.sh; do
        ln -sf "$DOTFILES_DIR/scripts/$s" "$scripts_dir/$s"
    done

    ln -sf "$DOTFILES_DIR/wallust/wallust.toml" "$scripts_dir/wallust.toml"

    for t in "$DOTFILES_DIR/wallust/templates"/*; do
        ln -sf "$t" "$scripts_dir/templates/"
    done

    ok "Wallust scripts and templates linked"
}

make_executable() {
    for d in "$CONFIG_DIR/waybar/scripts" "$CONFIG_DIR/rofi/scripts" "$CONFIG_DIR/wallust"; do
        for s in "$d"/*.sh; do
            chmod +x "$s" 2>/dev/null || true
        done
    done
    chmod +x "$HOME/.local/bin/hyprlogout" 2>/dev/null || true
    ok "Scripts made executable"
}

install_waybar_config() {
    mkdir -p "$CONFIG_DIR/waybar/scripts" "$CONFIG_DIR/waybar/colors"
    link_config "$DOTFILES_DIR/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc" "waybar"
    link_config "$DOTFILES_DIR/waybar/style.css" "$CONFIG_DIR/waybar/style.css" "waybar"
    link_config "$DOTFILES_DIR/waybar/colors/teto.css" "$CONFIG_DIR/waybar/colors/teto.css" "waybar"
    link_config "$DOTFILES_DIR/waybar/scripts/launch.sh" "$CONFIG_DIR/waybar/scripts/launch.sh" "waybar"
    link_config "$DOTFILES_DIR/waybar/scripts/media.sh" "$CONFIG_DIR/waybar/scripts/media.sh" "waybar"
    link_config "$DOTFILES_DIR/waybar/scripts/weather.sh" "$CONFIG_DIR/waybar/scripts/weather.sh" "waybar"
    for s in brightness.sh notification.sh system-wifi.sh system-bluetooth.sh system-audio.sh system-cpu.sh system-memory.sh power-profile.sh power-profile-switch.sh system-power.sh workspaces.sh workspace-click.sh workspace-next.sh workspace-prev.sh tui-wifi.sh tui-bluetooth.sh tui-audio.sh tui-cpu.sh; do
        link_config "$DOTFILES_DIR/waybar/scripts/$s" "$CONFIG_DIR/waybar/scripts/$s" "waybar"
    done
    for s in "$DOTFILES_DIR/scripts"/record*.sh; do
        link_config "$s" "$CONFIG_DIR/waybar/scripts/$(basename "$s")" "waybar"
    done
    link_config "$DOTFILES_DIR/scripts/workspace-monitor.sh" "$CONFIG_DIR/waybar/scripts/workspace-monitor.sh" "waybar"
}

install_hypr_config() {
    mkdir -p "$CONFIG_DIR/hypr"
    for f in "$DOTFILES_DIR/hypr"/*.lua; do
        link_config "$f" "$CONFIG_DIR/hypr/$(basename "$f")" "hyprland"
    done
}

install_swaync_config() {
    mkdir -p "$CONFIG_DIR/swaync"
    link_config "$DOTFILES_DIR/swaync/config.json" "$CONFIG_DIR/swaync/config.json" "swaync"
    link_config "$DOTFILES_DIR/swaync/style.css" "$CONFIG_DIR/swaync/style.css" "swaync"
    link_config "$DOTFILES_DIR/swaync/media-swaync.sh" "$CONFIG_DIR/swaync/media-swaync.sh" "swaync"
    link_config "$DOTFILES_DIR/swaync/bt-status.sh" "$CONFIG_DIR/swaync/bt-status.sh" "swaync"
}

install_gtk_config() {
    mkdir -p "$CONFIG_DIR/gtk-3.0" "$CONFIG_DIR/gtk-4.0"
    link_config "$DOTFILES_DIR/gtk/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini" "gtk3"
    link_config "$DOTFILES_DIR/gtk/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0/settings.ini" "gtk4"
}

install_wlogout_config() {
    mkdir -p "$CONFIG_DIR/wlogout/assets" "$CONFIG_DIR/wlogout/icons" "$CONFIG_DIR/wlogout/actions"
    link_config "$DOTFILES_DIR/wlogout/style.css" "$CONFIG_DIR/wlogout/style.css" "wlogout"
    link_config "$DOTFILES_DIR/wlogout/layout" "$CONFIG_DIR/wlogout/layout" "wlogout"
    for d in assets icons actions; do
        for f in "$DOTFILES_DIR/wlogout/$d"/*; do
            link_config "$f" "$CONFIG_DIR/wlogout/$d/$(basename "$f")" "wlogout"
        done
    done
}

install_rofi_config() {
    mkdir -p "$CONFIG_DIR/rofi/themes" "$CONFIG_DIR/rofi/colors" "$CONFIG_DIR/rofi/launchers" "$CONFIG_DIR/rofi/scripts" "$CONFIG_DIR/rofi/icons"
    link_config "$DOTFILES_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi/config.rasi" "rofi"
    for d in colors themes; do
        for f in "$DOTFILES_DIR/rofi/$d"/*.rasi; do
            link_config "$f" "$CONFIG_DIR/rofi/$d/$(basename "$f")" "rofi"
        done
    done
    for f in "$DOTFILES_DIR/rofi/launchers"/*; do
        [ -f "$f" ] && link_config "$f" "$CONFIG_DIR/rofi/launchers/$(basename "$f")" "rofi"
    done
    link_config "$DOTFILES_DIR/rofi/scripts/script_wallpaper.sh" "$CONFIG_DIR/rofi/scripts/script_wallpaper.sh" "rofi"
    link_config "$DOTFILES_DIR/rofi/scripts/system-power.sh" "$CONFIG_DIR/rofi/scripts/system-power.sh" "rofi"
    link_config "$DOTFILES_DIR/rofi/scripts/clipboard.sh" "$CONFIG_DIR/rofi/scripts/clipboard.sh" "rofi"
    # Icons
    link_config "$DOTFILES_DIR/icons/lock-outline-sharp.svg" "$CONFIG_DIR/rofi/icons/lock.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/logout-sharp.svg" "$CONFIG_DIR/rofi/icons/logout.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/sleep.svg" "$CONFIG_DIR/rofi/icons/sleep.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/reboot.svg" "$CONFIG_DIR/rofi/icons/reboot.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/shutdown.svg" "$CONFIG_DIR/rofi/icons/shutdown.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/cancel-outline.svg" "$CONFIG_DIR/rofi/icons/cancel.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/static.svg" "$CONFIG_DIR/rofi/icons/static.svg" "rofi"
    link_config "$DOTFILES_DIR/icons/live.svg" "$CONFIG_DIR/rofi/icons/live.svg" "rofi"
}

install_cava_config() {
    mkdir -p "$CONFIG_DIR/cava/themes" "$CONFIG_DIR/cava/shaders"
    link_config "$DOTFILES_DIR/cava/config" "$CONFIG_DIR/cava/config" "cava"
    for f in "$DOTFILES_DIR/cava/shaders"/*; do
        link_config "$f" "$CONFIG_DIR/cava/shaders/$(basename "$f")" "cava"
    done
}

link_dotfiles() {
    log "Linking dotfiles..."
    install_waybar_config
    install_hypr_config
    install_swaync_config
    install_gtk_config
    install_wlogout_config
    install_rofi_config
    install_cava_config
    mkdir -p "$CONFIG_DIR/kitty"
    link_config "$DOTFILES_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf" "kitty"
    mkdir -p "$CONFIG_DIR/environment.d"
    link_config "$DOTFILES_DIR/environment.d/qt.conf" "$CONFIG_DIR/environment.d/qt.conf" "qt"
    mkdir -p "$CONFIG_DIR/fish"
    link_config "$DOTFILES_DIR/fish/config.fish" "$CONFIG_DIR/fish/config.fish" "fish"
    mkdir -p "$CONFIG_DIR/fastfetch"
    link_config "$DOTFILES_DIR/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc" "fastfetch"
    link_config "$DOTFILES_DIR/fastfetch/bitz.txt" "$CONFIG_DIR/fastfetch/bitz.txt" "fastfetch"
}

fix_paths() {
    log "Fixing hardcoded paths..."
    local files=(
        "$DOTFILES_DIR/rofi/config.rasi"
        "$DOTFILES_DIR/rofi/scripts/script_wallpaper.sh"
        "$DOTFILES_DIR/rofi/launchers/type-6/style-4.rasi"
        "$DOTFILES_DIR/rofi/themes/wallpaper-grid.rasi"
    )
    for file in "${files[@]}"; do
        [ -f "$file" ] && sed -i "s|/home/lucario|$HOME|g; s|/home/bitz|$HOME|g" "$file" 2>/dev/null || true
    done
    ok "Paths fixed"
}

add_keybind() {
    local keybind_file="$CONFIG_DIR/hypr/keybinds.lua"
    [ -f "$keybind_file" ] || return
    grep -q "wallpaper-select" "$keybind_file" 2>/dev/null && return
    echo "" >> "$keybind_file"
    echo "-- Wallpaper selector" >> "$keybind_file"
    echo 'hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/wallust/wallpaper-select.sh"))' >> "$keybind_file"
    ok "Keybind added: SUPER+SHIFT+W = wallpaper picker"
}

generate_initial_theme() {
    command -v wallust &>/dev/null || { warn "wallust not installed — skipping theme generation"; return; }

    local initial_wall=""
    for img in $(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort); do
        if wallust run "$img" --config-dir "$CONFIG_DIR/wallust" -q 2>/dev/null; then
            initial_wall="$img"
            break
        fi
    done

    [ -n "$initial_wall" ] || { warn "No suitable wallpaper found — skipping theme generation"; return; }

    log "Generating theme from: $(basename "$initial_wall")"
    echo "$initial_wall" > "$CACHE_DIR/current_wallpaper.txt" 2>/dev/null || true
    ln -sf "$initial_wall" "$CACHE_DIR/current_wallpaper.png" 2>/dev/null || true

    if command -v awww &>/dev/null; then
        pgrep -x awww-daemon > /dev/null 2>&1 || { awww-daemon & sleep 0.5; }
        awww img "$initial_wall" --transition-type grow --transition-duration 1 2>/dev/null || true
    fi

    ok "Theme generated from $(basename "$initial_wall")"
}

install_systemd_services() {
    log "Installing systemd services..."
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
    cp "$DOTFILES_DIR/systemd/user/wallust-cache-daemon.service" \
       "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/wallust-cache-daemon.service"
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now wallust-cache-daemon.service 2>/dev/null || true
    ok "wallust-cache-daemon service started"

    if command -v bluetoothctl &>/dev/null; then
        sudo rfkill unblock bluetooth 2>/dev/null || true
        sudo systemctl enable --now bluetooth.service 2>/dev/null || true
        ok "Bluetooth service enabled"
    fi
}

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}╔══════════════════════════════════╗${NC}"
echo -e "${CYAN}║     bitzdots — Auto Installer     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════╝${NC}"
echo ""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            echo "Usage: $0"
            echo ""
            echo "  --help         Show this help"
            exit 0
            ;;
    esac
    shift
done

install_deps
setup_wallpapers
setup_cache
mkdir -p "$HOME/Pictures/Screenshots/Fullscreen" "$HOME/Pictures/Screenshots/Freeform" 2>/dev/null || true
install_nerd_font
install_scripts
link_dotfiles
make_executable
setup_runcat
fix_paths
add_keybind
generate_initial_theme
install_systemd_services

echo ""
echo -e "${GREEN}╔══════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation complete!       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════╝${NC}"
echo ""
echo -e "  ${YELLOW}Usage:${NC}"
echo "    SUPER+SHIFT+W    — Open wallpaper picker"
echo ""
echo -e "  ${YELLOW}Or run manually:${NC}"
echo "    ~/.config/wallust/wallpaper-select.sh"
echo ""
echo -e "  ${YELLOW}Notes:${NC}"
echo "    • Add wallpapers to $WALL_DIR/"
echo "    • Add live wallpapers (.mp4/.webm/.gif) to $WALL_DIR/live/"
echo "    • To manually generate theme: wallust run <wallpaper>"
echo "    • Install mpvpaper for live wallpaper support"
echo ""
