#!/bin/bash
# Rofi wallpaper selector with automatic theme generation via wallust
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
WALL_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
ROFI_THEME="$CONFIG_DIR/rofi/themes/wallpaper-grid.rasi"
LIVE_DIR="$WALL_DIR/live"

mkdir -p "$CACHE_DIR"

if [ ! -d "$WALL_DIR" ]; then
    notify-send -u critical "Wallpapers not found" "Directory $WALL_DIR does not exist"
    exit 1
fi

# ── Helper: set static wallpaper ─────────────────────────────────
set_static() {
    local img="$1"

    if ! command -v wallust &>/dev/null; then
        notify-send -u critical "wallust not installed"
        exit 1
    fi

    echo "$img" > "$CACHE_DIR/current_wallpaper.txt"
    ln -sf "$img" "$CACHE_DIR/current_wallpaper.png" 2>/dev/null || true

    if command -v awww &>/dev/null; then
        if ! pgrep -x awww-daemon > /dev/null; then
            awww-daemon &
            sleep 0.5
        fi
        awww img "$img" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 2 \
            --transition-fps 60
    fi

    wallust run "$img" --config-dir "$CONFIG_DIR/wallust"

    # Reload themed apps
    "$CONFIG_DIR/wallust/reload-theme.sh"

    notify-send -i "$img" "Theme updated" "Wallpaper and colors applied"
}

# ── Helper: set live wallpaper ───────────────────────────────────
set_live() {
    local video="$1"

    if ! command -v mpvpaper &>/dev/null; then
        notify-send -u critical "mpvpaper not installed" "Install mpvpaper for live wallpapers"
        exit 1
    fi

    echo "$video" > "$CACHE_DIR/current_wallpaper.txt"

    # Kill any existing mpvpaper instance
    pkill mpvpaper 2>/dev/null || true

    # Play video as wallpaper
    mpvpaper -o "loop no-audio" '*' "$video"

    # Generate colors from a frame if ffmpeg is available
    if command -v ffmpeg &>/dev/null && command -v wallust &>/dev/null; then
        local frame="$CACHE_DIR/live-frame.jpg"
        ffmpeg -i "$video" -vframes 1 "$frame" -y 2>/dev/null || true
        if [ -f "$frame" ]; then
            ln -sf "$frame" "$CACHE_DIR/current_wallpaper.png" 2>/dev/null || true
            wallust run "$frame" --config-dir "$CONFIG_DIR/wallust"
            "$CONFIG_DIR/wallust/reload-theme.sh"
        fi
    fi

    notify-send -i video "Live wallpaper" "$(basename "$video")"
}

# ── Pick static wallpaper ────────────────────────────────────────
pick_static() {
    local selected
    selected=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | while read -r f; do
            echo -ne "$f\0icon\x1f$f\n"
        done \
        | rofi -dmenu -i -theme "$ROFI_THEME" -p "  " -show-icons)

    if [ -z "$selected" ]; then
        return 1
    fi

    if [ ! -f "$selected" ]; then
        selected="$WALL_DIR/$selected"
    fi

    if [ ! -f "$selected" ]; then
        notify-send -u critical "Wallpaper not found" "$selected"
        return 1
    fi

    set_static "$selected"
}

# ── Pick live wallpaper ──────────────────────────────────────────
pick_live() {
    if [ ! -d "$LIVE_DIR" ]; then
        notify-send -u critical "No live wallpapers" "Directory $LIVE_DIR does not exist"
        return 1
    fi

    local selected
    selected=$(find "$LIVE_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.gif" \) \
        | while read -r f; do
            echo -ne "$f\0icon\x1f$f\n"
        done \
        | rofi -dmenu -i -theme "$ROFI_THEME" -p "  " -show-icons)

    if [ -z "$selected" ]; then
        return 1
    fi

    if [ ! -f "$selected" ]; then
        selected="$LIVE_DIR/$selected"
    fi

    if [ ! -f "$selected" ]; then
        notify-send -u critical "Video not found" "$selected"
        return 1
    fi

    set_live "$selected"
}

# ── Main menu ────────────────────────────────────────────────────
main_menu() {
    local has_live=false
    [ -d "$LIVE_DIR" ] && [ "$(find "$LIVE_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)" -gt 0 ] && has_live=true

    local options="Static wallpaper"
    $has_live && options="$options\nLive wallpaper"

    local choice
    choice=$(echo -e "$options" | rofi -dmenu -i -theme "$ROFI_THEME" -p "  ")

    case "$choice" in
        "Static wallpaper") pick_static ;;
        "Live wallpaper")   pick_live ;;
        *) exit 0 ;;
    esac
}

# ── Entry point ──────────────────────────────────────────────────
if [ $# -eq 1 ] && [ -f "$1" ]; then
    set_static "$1"
elif [ $# -eq 1 ] && [ "$1" = "--live" ]; then
    pick_live
else
    main_menu
fi
