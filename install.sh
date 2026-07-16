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

# ── Detect distro ────────────────────────────────────────────────
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
            # pacman packages
            sudo pacman -S --needed --noconfirm \
                waybar swaync rofi kitty cava \
                awww hyprpicker wl-clipboard playerctl pavucontrol \
                polkit-kde-agent grim slurp cliphist hyprlock ffmpeg \
                impala bluetui btop pulsemixer wf-recorder python 2>&1 | \
                grep -o "target not found: [^']*" | cut -d' ' -f4 > /tmp/missing_pkgs.txt || true


            # AUR packages via paru
            if command -v paru &>/dev/null && [ -s /tmp/missing_pkgs.txt ]; then
                local aur_pkgs=()
                while IFS= read -r pkg; do
                    aur_pkgs+=("$pkg")
                done < /tmp/missing_pkgs.txt
                log "Installing AUR packages via paru: ${aur_pkgs[*]}"
                paru -S --needed --noconfirm "${aur_pkgs[@]}"
            elif [ -s /tmp/missing_pkgs.txt ]; then
                warn "paru not found. Install AUR packages manually:"
                while IFS= read -r pkg; do
                    echo "  paru -S $pkg"
                done < /tmp/missing_pkgs.txt
            fi
            rm -f /tmp/missing_pkgs.txt
            ;;
        fedora)
            log "Installing packages (Fedora)..."
            # wallust may need to be installed from copr or cargo
            sudo dnf install -y \
                waybar swaync wlogout rofi kitty cava \
                awww hyprpicker wl-clipboard playerctl pavucontrol \
                polkit-kde-agent grim slurp cliphist hyprlock ffmpeg
            # Install wallust from crates.io
            if ! command -v wallust &>/dev/null; then
                warn "wallust not in repos, installing via cargo..."
                cargo install wallust
            fi
            ;;
        debian)
            log "Installing packages (Debian/Ubuntu)..."
            sudo apt install -y \
                waybar swaync wlogout rofi kitty cava \
                awww hyprpicker wl-clipboard playerctl pavucontrol \
                polkit-kde-agent grim slurp cliphist hyprlock ffmpeg
            if ! command -v wallust &>/dev/null; then
                warn "wallust not in repos, installing via cargo..."
                cargo install wallust
            fi
            ;;
        nixos)
            log "NixOS detected — add these to your configuration.nix:"
            echo "  services.awww.enable = true;"
            echo "  programs.waybar.enable = true;"
            echo "  programs.rofi.enable = true;"
            echo "  environment.systemPackages = with pkgs; ["
            echo "    wallust swaync wlogout kitty cava"
            echo "    hyprpicker wl-clipboard playerctl pavucontrol"
            echo "    polkit-kde-agent grim slurp cliphist hyprlock ffmpeg"
            echo "  ];"
            ;;
        *)
            warn "Unknown distro. Please install manually:"
            echo "  - wallust (https://github.com/explosion-mental/wallust)"
            echo "  - waybar, swaync, wlogout, rofi, kitty, cava"
            echo "  - awww, hyprpicker, wl-clipboard, playerctl"
            echo "  - pavucontrol, polkit-kde-agent, grim, slurp, cliphist"
            echo "  - hyprlock, ffmpeg"
            ;;
    esac
}

install_nerd_font() {
    if fc-list :family 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        ok "JetBrainsMono Nerd Font already installed"
        return
    fi

    log "Installing JetBrainsMono Nerd Font from AUR..."

    if command -v paru &>/dev/null; then
        paru -S --needed --noconfirm ttf-jetbrains-mono-nerd && {
            ok "JetBrainsMono Nerd Font installed via paru"
            return
        }
    fi

    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm ttf-jetbrains-mono-nerd && {
            ok "JetBrainsMono Nerd Font installed via yay"
            return
        }
    fi

    warn "No AUR helper found (paru/yay). Install manually: paru -S ttf-jetbrains-mono-nerd"
}

link_config() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ ! -e "$src" ]; then
        warn "$name source not found: $src — skipping"
        return
    fi

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        warn "$name config exists at $dest — backing up to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    if [ -L "$dest" ]; then
        log "$name config already linked"
        return
    fi

    ln -sf "$src" "$dest"
    ok "$name config linked: $src → $dest"
}

setup_wallpapers() {
    mkdir -p "$WALL_DIR" "$WALL_DIR/live"

    # Copy default wallpapers from repo
    if [ -f "$DOTFILES_DIR/hypr/wallpapers/default.jpg" ]; then
        cp -n "$DOTFILES_DIR/hypr/wallpapers/default.jpg" "$WALL_DIR/" 2>/dev/null || true
        ok "Copied default wallpaper"
    fi

    if [ -f "$DOTFILES_DIR/hypr/wallpapers/lockscreen.jpg" ]; then
        cp -n "$DOTFILES_DIR/hypr/wallpapers/lockscreen.jpg" "$WALL_DIR/" 2>/dev/null || true
    fi

    ok "Wallpaper directories ready: $WALL_DIR/ and $WALL_DIR/live/"
}

setup_cache() {
    mkdir -p "$CACHE_DIR"
}

setup_runcat() {
    local module_dir="$CONFIG_DIR/waybar/modules/runcat-text"

    if [ ! -d "$DOTFILES_DIR/waybar/modules/runcat-text" ]; then
        warn "runcat-text module not found in dotfiles — skipping"
        return
    fi

    mkdir -p "$module_dir"
    cp "$DOTFILES_DIR/waybar/modules/runcat-text"/* "$module_dir/"
    ok "runcat-text module files copied"

    # Install font
    local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    mkdir -p "$font_dir"
    if [ -f "$module_dir/runcat.ttf" ] && ! fc-list :family 2>/dev/null | grep -qi "runcat"; then
        cp "$module_dir/runcat.ttf" "$font_dir/"
        fc-cache -f 2>/dev/null || true
        ok "runcat font installed"
    else
        ok "runcat font already installed"
    fi

    # Set up Python venv
    if [ ! -f "$module_dir/.venv/bin/python" ]; then
        if command -v python &>/dev/null; then
            python -m venv "$module_dir/.venv"
            "$module_dir/.venv/bin/pip" install -q "$module_dir/requirements.txt" 2>/dev/null || \
                "$module_dir/.venv/bin/pip" install -q pyjson5 2>/dev/null || \
                warn "runcat Python deps not installed (pyjson5 missing)"
            ok "runcat Python venv created"
        else
            warn "python not found — runcat-text requires python"
        fi
    else
        ok "runcat Python venv already exists"
    fi

    ok "runcat-text setup complete"
}

install_scripts() {
    local scripts_dir="$CONFIG_DIR/wallust"

    mkdir -p "$scripts_dir/templates"

    # Install scripts
    for s in reload-theme.sh wallpaper-select.sh cache-wallpapers.sh record-fullscreen.sh record-region.sh recording-indicator.sh; do
        ln -sf "$DOTFILES_DIR/scripts/$s" "$scripts_dir/$s"
    done
    ok "wallust scripts linked"

    # Install wallust config
    ln -sf "$DOTFILES_DIR/wallust/wallust.toml" "$scripts_dir/wallust.toml"
    ok "wallust.toml linked"

    # Install templates
    for t in "$DOTFILES_DIR/wallust/templates"/*; do
        ln -sf "$t" "$scripts_dir/templates/"
    done
    ok "wallust templates linked"
}

make_executable() {
    for s in "$CONFIG_DIR/waybar/scripts"/*.sh; do
        chmod +x "$s" 2>/dev/null || true
    done
    for s in "$CONFIG_DIR/rofi/scripts"/*.sh; do
        chmod +x "$s" 2>/dev/null || true
    done
    for s in "$CONFIG_DIR/wallust"/*.sh; do
        chmod +x "$s" 2>/dev/null || true
    done
    chmod +x "$CONFIG_DIR/rofi/scripts/script_wallpaper.sh" 2>/dev/null || true
    ok "Scripts made executable"
}

link_dotfiles() {
    log "Linking dotfiles..."

    mkdir -p "$CONFIG_DIR/waybar"
    mkdir -p "$CONFIG_DIR/swaync"
    mkdir -p "$CONFIG_DIR/wlogout"
    mkdir -p "$CONFIG_DIR/hypr"
    mkdir -p "$CONFIG_DIR/rofi"
    mkdir -p "$CONFIG_DIR/cava"
    mkdir -p "$CONFIG_DIR/kitty"
    mkdir -p "$CONFIG_DIR/waybar/scripts"
    mkdir -p "$CONFIG_DIR/waybar/colors"
    mkdir -p "$CONFIG_DIR/cava/themes"
    mkdir -p "$CONFIG_DIR/cava/shaders"
    mkdir -p "$CONFIG_DIR/wlogout/assets"
    mkdir -p "$CONFIG_DIR/wlogout/icons"
    mkdir -p "$CONFIG_DIR/swaync"
    mkdir -p "$CONFIG_DIR/rofi/themes"
    mkdir -p "$CONFIG_DIR/rofi/colors"
    mkdir -p "$CONFIG_DIR/rofi/launchers"
    mkdir -p "$CONFIG_DIR/rofi/scripts"
    mkdir -p "$CONFIG_DIR/rofi/icons"
    mkdir -p "$CONFIG_DIR/gtk-3.0"
    mkdir -p "$CONFIG_DIR/gtk-4.0"
    # Waybar
    link_config "$DOTFILES_DIR/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc" "waybar"
    link_config "$DOTFILES_DIR/waybar/style.css" "$CONFIG_DIR/waybar/style.css" "waybar"
    link_config "$DOTFILES_DIR/waybar/colors/teto.css" "$CONFIG_DIR/waybar/colors/teto.css" "waybar"
    link_config "$DOTFILES_DIR/waybar/scripts/launch.sh" "$CONFIG_DIR/waybar/scripts/launch.sh" "waybar"
    link_config "$DOTFILES_DIR/waybar/scripts/media.sh" "$CONFIG_DIR/waybar/scripts/media.sh" "waybar"
    link_config "$DOTFILES_DIR/waybar/scripts/weather.sh" "$CONFIG_DIR/waybar/scripts/weather.sh" "waybar"
    for s in brightness.sh notification.sh system-wifi.sh system-bluetooth.sh system-audio.sh system-cpu.sh system-memory.sh power-profile.sh power-profile-switch.sh system-power.sh workspaces.sh workspace-click.sh workspace-next.sh workspace-prev.sh tui-wifi.sh tui-bluetooth.sh tui-audio.sh tui-cpu.sh record-*.sh; do
        link_config "$DOTFILES_DIR/waybar/scripts/$s" "$CONFIG_DIR/waybar/scripts/$s" "waybar"
    done

    # Hyprland
    for f in "$DOTFILES_DIR/hypr"/*.lua; do
        link_config "$f" "$CONFIG_DIR/hypr/$(basename "$f")" "hyprland"
    done

    # SwayNC
    link_config "$DOTFILES_DIR/swaync/config.json" "$CONFIG_DIR/swaync/config.json" "swaync"
    link_config "$DOTFILES_DIR/swaync/style.css" "$CONFIG_DIR/swaync/style.css" "swaync"
    link_config "$DOTFILES_DIR/swaync/media-swaync.sh" "$CONFIG_DIR/swaync/media-swaync.sh" "swaync"
    link_config "$DOTFILES_DIR/swaync/bt-status.sh" "$CONFIG_DIR/swaync/bt-status.sh" "swaync"

    # GTK3/4 dark theme
    link_config "$DOTFILES_DIR/gtk/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini" "gtk3"
    link_config "$DOTFILES_DIR/gtk/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0/settings.ini" "gtk4"

    # Wlogout
    link_config "$DOTFILES_DIR/wlogout/style.css" "$CONFIG_DIR/wlogout/style.css" "wlogout"
    link_config "$DOTFILES_DIR/wlogout/layout" "$CONFIG_DIR/wlogout/layout" "wlogout"
    for f in "$DOTFILES_DIR/wlogout/assets"/*; do
        link_config "$f" "$CONFIG_DIR/wlogout/assets/$(basename "$f")" "wlogout"
    done
    for f in "$DOTFILES_DIR/wlogout/icons"/*; do
        link_config "$f" "$CONFIG_DIR/wlogout/icons/$(basename "$f")" "wlogout"
    done

    # Rofi
    link_config "$DOTFILES_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi/config.rasi" "rofi"
    for f in "$DOTFILES_DIR/rofi/colors"/*.rasi; do
        link_config "$f" "$CONFIG_DIR/rofi/colors/$(basename "$f")" "rofi"
    done
    for f in "$DOTFILES_DIR/rofi/themes"/*.rasi; do
        link_config "$f" "$CONFIG_DIR/rofi/themes/$(basename "$f")" "rofi"
    done
    for f in "$DOTFILES_DIR/rofi/launchers"/*; do
        if [ -f "$f" ]; then link_config "$f" "$CONFIG_DIR/rofi/launchers/$(basename "$f")" "rofi"; fi
    done
    link_config "$DOTFILES_DIR/rofi/scripts/script_wallpaper.sh" "$CONFIG_DIR/rofi/scripts/script_wallpaper.sh" "rofi"
    link_config "$DOTFILES_DIR/rofi/scripts/system-power.sh" "$CONFIG_DIR/rofi/scripts/system-power.sh" "rofi"
    link_config "$DOTFILES_DIR/rofi/scripts/clipboard.sh" "$CONFIG_DIR/rofi/scripts/clipboard.sh" "rofi"

    # Cava
    link_config "$DOTFILES_DIR/cava/config" "$CONFIG_DIR/cava/config" "cava"
    for f in "$DOTFILES_DIR/cava/shaders"/*; do
        link_config "$f" "$CONFIG_DIR/cava/shaders/$(basename "$f")" "cava"
    done

    # Kitty — link config from dotfiles
    link_config "$DOTFILES_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf" "kitty"
}

# ── Fix hardcoded paths ─────────────────────────────────────────
fix_paths() {
    log "Fixing hardcoded paths (if any)..."

    local files=(
        "$DOTFILES_DIR/rofi/config.rasi"
        "$DOTFILES_DIR/rofi/scripts/script_wallpaper.sh"
        "$DOTFILES_DIR/rofi/launchers/type-6/style-4.rasi"
        "$DOTFILES_DIR/rofi/themes/wallpaper-grid.rasi"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            sed -i "s|/home/lucario|$HOME|g; s|/home/bitz|$HOME|g" "$file" 2>/dev/null || true
        fi
    done

    ok "Paths fixed in repo files"
}

# ── Keybind for wallpaper picker ─────────────────────────────────
add_keybind() {
    local keybind_file="$CONFIG_DIR/hypr/keybinds.lua"
    local line='hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/wallust/wallpaper-select.sh"))'

    if [ -f "$keybind_file" ]; then
        if ! grep -q "wallpaper-select" "$keybind_file" 2>/dev/null; then
            echo "" >> "$keybind_file"
            echo "-- Wallpaper selector" >> "$keybind_file"
            echo "$line" >> "$keybind_file"
            ok "Keybind added: SUPER+SHIFT+W = wallpaper picker"
        else
            ok "Keybind already exists"
        fi
    fi
}

# ── Generate initial theme ──────────────────────────────────────
generate_initial_theme() {
    local initial_wall

    for img in $(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort); do
        if wallust run "$img" --config-dir "$CONFIG_DIR/wallust" -q 2>/dev/null; then
            initial_wall="$img"
            break
        fi
    done

    if [ -z "$initial_wall" ]; then
        warn "No suitable wallpaper found in $WALL_DIR — skipping initial theme"
        return
    fi

    log "Generating initial theme from: $(basename "$initial_wall")"

    # Cache it so autostart restores it
    echo "$initial_wall" > "$CACHE_DIR/current_wallpaper.txt" 2>/dev/null || true
    ln -sf "$initial_wall" "$CACHE_DIR/current_wallpaper.png" 2>/dev/null || true

    # Set wallpaper now if awww is available
    if command -v awww &>/dev/null; then
        if ! pgrep -x awww-daemon > /dev/null 2>&1; then
            awww-daemon &
            sleep 0.5
        fi
        awww img "$initial_wall" --transition-type grow --transition-duration 1 2>/dev/null || true
    fi

    ok "Initial theme generated from $(basename "$initial_wall")"
}

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}╔══════════════════════════════════╗${NC}"
echo -e "${CYAN}║     bitzdots — Auto Installer     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════╝${NC}"
echo ""

# Parse args
INSTALL_DEPS=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-deps) INSTALL_DEPS=true ;;
        --help|-h)
            echo "Usage: $0 [--with-deps]"
            echo ""
            echo "  --with-deps    Automatically install system dependencies"
            echo "  --help         Show this help"
            exit 0
            ;;
    esac
    shift
done

if [ "$INSTALL_DEPS" = true ]; then
    install_deps
else
    warn "Skipping dependency installation (use --with-deps to auto-install)"
    echo "  Required packages: wallust, waybar, swaync, wlogout, rofi, kitty"
    echo "  Optional: awww (already installed), cava"
fi

setup_wallpapers
setup_cache
install_nerd_font
install_scripts
link_dotfiles
make_executable
setup_runcat
fix_paths
add_keybind
generate_initial_theme

echo ""
echo -e "${GREEN}╔══════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation complete!            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════╝${NC}"
echo ""
echo -e "  ${YELLOW}Usage:${NC}"
echo "    SUPER+SHIFT+W    — Open wallpaper picker"
echo ""
echo -e "  ${YELLOW}Or run manually:${NC}"
echo "    ~/.config/wallust/wallpaper-select.sh"
echo ""
echo -e "  ${YELLOW}Notes:${NC}"
echo "    • Add static wallpapers to $WALL_DIR/"
echo "    • Add live wallpapers (.mp4/.webm/.gif) to $WALL_DIR/live/"
echo "    • To manually generate theme: wallust run <wallpaper>"
echo "    • Edit templates in ~/.config/wallust/templates/"
echo "    • Install mpvpaper for live wallpaper support"
echo ""
