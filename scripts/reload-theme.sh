#!/bin/bash
# Notify themed applications that colors changed
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo ":: Theme files updated..."

# Source environment variables from wallust
if [ -f "$CONFIG_DIR/wallust/env" ]; then
    source "$CONFIG_DIR/wallust/env"
fi

# Fix ~ not being expanded by qt6ct in color_scheme_path
if [ -f "$CONFIG_DIR/qt6ct/qt6ct.conf" ]; then
    sed -i "s|^color_scheme_path=~|color_scheme_path=$HOME|" "$CONFIG_DIR/qt6ct/qt6ct.conf" 2>/dev/null || true
fi

# --- SwayNC : reload CSS in-place ---
if pgrep -x swaync > /dev/null; then
    swaync-client --reload-css 2>/dev/null || swaync-client -R 2>/dev/null || true
    echo "   SwayNC CSS reloaded"
fi

# --- Hyprland border colors: update via keyword (compatible across all versions) ---
if command -v hyprctl &>/dev/null && [ -f "$CONFIG_DIR/hypr/colors.lua" ]; then
    c1=$(grep "color1" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/" || true)
    c4=$(grep "color4" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/" || true)
    c8=$(grep "color8" "$CONFIG_DIR/hypr/colors.lua" | head -1 | sed "s/.*= \"\(.*\)\",/\1/" || true)
    if [ -n "$c1" ] && [ -n "$c4" ]; then
        hyprctl keyword general:col.active_border "rgba(${c1}ee) rgba(${c4}ee) 45deg" &>/dev/null || true
    fi
    if [ -n "$c8" ]; then
        hyprctl keyword general:col.inactive_border "rgba(${c8}ee)" &>/dev/null || true
    fi
    echo "   Hyprland border colors updated"
fi

echo ":: Theme reload complete!"
