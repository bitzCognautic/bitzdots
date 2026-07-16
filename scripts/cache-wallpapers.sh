#!/bin/bash
# Background wallpaper color cache daemon
# Pre-generates wallust color schemes so theme switching is instant

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
WALL_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
THEME_CACHE="$CACHE_DIR/wallust/themes"
LIVE_DIR="$WALL_DIR/live"
POLL_INTERVAL=30

mkdir -p "$THEME_CACHE"

WALLUST_OUTPUTS=(
    "waybar/style.css"
    "waybar/config.jsonc"
    "swaync/style.css"
    "wlogout/style.css"
    "hypr/colors.lua"
    "kitty/colors.conf"
    "cava/themes/generated"
    "rofi/theme-generated.rasi"
    "wallust/env"
    "wallust/browser-colors.css"
    "rofi/themes/wallpaper-grid.rasi"
    "rofi/themes/power.rasi"
    "rofi/icons/lock.svg"
    "rofi/icons/logout.svg"
    "rofi/icons/sleep.svg"
    "rofi/icons/reboot.svg"
    "rofi/icons/shutdown.svg"
    "rofi/icons/cancel.svg"
    "rofi/icons/static.svg"
    "rofi/icons/live.svg"
    "kdeglobals"
    "bitzdots.colors"
    "qt6ct/qt6ct.conf"
)

cache_wallpaper() {
    local img="$1"
    local name
    name="$(basename "$img" | sed 's/\.[^.]*$//')"
    local cache_dir="$THEME_CACHE/$name"
    local marker="$cache_dir/.done"

    # Check if cache is still fresh (wallpaper mtime older than cache)
    if [ -f "$marker" ] && [ "$(stat -c %Y "$img" 2>/dev/null)" -le "$(stat -c %Y "$marker" 2>/dev/null)" ]; then
        return 0
    fi

    mkdir -p "$cache_dir"

    if ! wallust run "$img" --config-dir "$CONFIG_DIR/wallust" -q 2>/dev/null; then
        return 1
    fi

    for output in "${WALLUST_OUTPUTS[@]}"; do
        local src="$CONFIG_DIR/$output"
        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$cache_dir/$output")"
            cp "$src" "$cache_dir/$output"
        fi
    done

    touch "$marker"
}

scan_and_cache() {
    local found=0

    while IFS= read -r -d '' f; do
        cache_wallpaper "$f" && found=$((found + 1))
    done < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 2>/dev/null)

    if [ -d "$LIVE_DIR" ]; then
        while IFS= read -r -d '' f; do
            # Live wallpapers: extract a frame and cache that
            local name
            name="$(basename "$f" | sed 's/\.[^.]*$//')"
            local cache_dir="$THEME_CACHE/$name"
            local marker="$cache_dir/.done"

            if [ -f "$marker" ] && [ "$(stat -c %Y "$f" 2>/dev/null)" -le "$(stat -c %Y "$marker" 2>/dev/null)" ]; then
                continue
            fi

            if command -v ffmpeg &>/dev/null; then
                local frame
                frame="$(mktemp /tmp/wallust-frame-XXXXXX.jpg)"
                ffmpeg -i "$f" -vframes 1 "$frame" -y 2>/dev/null || { rm -f "$frame"; continue; }
                cache_wallpaper "$frame"
                rm -f "$frame"
            fi
        done < <(find "$LIVE_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.gif" \) -print0 2>/dev/null)
    fi

    [ "$found" -gt 0 ] && echo "cached $found wallpapers"
    return 0
}

# Daemon mode — loop forever
if [ "${1:-}" = "--daemon" ]; then
    while true; do
        scan_and_cache
        sleep "$POLL_INTERVAL"
    done
else
    scan_and_cache
fi
