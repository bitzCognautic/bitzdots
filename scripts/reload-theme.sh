#!/bin/bash
# Notify themed applications that colors changed — no kill commands, no app restarts
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo ":: Theme files updated..."

# Source environment variables from wallust
if [ -f "$CONFIG_DIR/wallust/env" ]; then
    source "$CONFIG_DIR/wallust/env"
fi

# --- SwayNC : reload CSS in-place ---
if pgrep -x swaync > /dev/null; then
    swaync-client --reload-css 2>/dev/null || swaync-client -R 2>/dev/null || true
    echo "   SwayNC CSS reloaded"
fi

# --- Hyprland border colors: update via eval (avoids full config reload) ---
if command -v hyprctl &>/dev/null && [ -f "$CONFIG_DIR/hypr/colors.lua" ]; then
    c1=$(grep "color1" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/")
    c4=$(grep "color4" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/")
    c8=$(grep "color8" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/")
    [ -n "$c1" ] && [ -n "$c4" ] && hyprctl eval "hl.config({ general = { col = { active_border = { colors = {\"rgba(${c1}ee)\", \"rgba(${c4}ee)\"}, angle = 45 }, inactive_border = \"rgba(${c8}ee)\" } } })" &>/dev/null || true
    echo "   Hyprland border colors updated"
fi

echo ":: Theme reload complete!"
