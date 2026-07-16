#!/bin/bash
# Notify themed applications that colors changed — no kill commands, no app restarts
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo ":: Theme files updated..."

# Source environment variables from wallust
if [ -f "$CONFIG_DIR/wallust/env" ]; then
    source "$CONFIG_DIR/wallust/env"
fi

# --- SwayNC : reload CSS in-place (not a kill) ---
if pgrep -x swaync > /dev/null; then
    swaync-client --reload-css 2>/dev/null || swaync-client -R 2>/dev/null || true
    echo "   SwayNC CSS reloaded"
fi

# --- Hyprland border colors: update via hyprctl keyword (not a reload) ---
if command -v hyprctl &>/dev/null && [ -f "$CONFIG_DIR/hypr/colors.lua" ]; then
    c1=$(grep "color1" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/")
    c4=$(grep "color4" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/")
    c8=$(grep "color8" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/")
    [ -n "$c1" ] && hyprctl keyword general:col.active_border "rgba(${c1}ee) rgba(${c4}ee) 45deg" &>/dev/null || true
    [ -n "$c8" ] && hyprctl keyword general:col.inactive_border "rgba(${c8}ee)" &>/dev/null || true
    echo "   Hyprland border colors updated"
fi

# Waybar reads colors-waybar.css live — no signal needed
# Kitty reads colors.conf from kitty.conf at next launch — no signal needed
# Rofi reads theme-generated.rasi on next invocation — no signal needed

echo ":: Theme reload complete!"
