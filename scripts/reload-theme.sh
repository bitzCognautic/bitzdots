#!/bin/bash
# Reload all themed applications after wallust generates new colors
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo ":: Reloading theme..."

# Source environment variables from wallust
if [ -f "$CONFIG_DIR/wallust/env" ]; then
    source "$CONFIG_DIR/wallust/env"
fi

# --- Waybar ---
if pgrep -x waybar > /dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null
    echo "   Waybar reloaded (SIGUSR2)"
fi

# --- SwayNC ---
if pgrep -x swaync > /dev/null; then
    swaync-client --reload-css 2>/dev/null || swaync-client -R 2>/dev/null || true
    echo "   SwayNC CSS reloaded"
fi

# --- Wlogout (no live reload, just kill existing) ---
if pgrep -x wlogout > /dev/null; then
    killall wlogout 2>/dev/null || true
fi

# --- Kitty ---
# Reload kitty colors by sending SIGUSR1 if kitty is running
if pgrep -x kitty > /dev/null; then
    pkill -SIGUSR1 kitty 2>/dev/null || true
    echo "   Kitty colors reloaded (SIGUSR1)"
fi

# --- Hyprland borders ---
if command -v hyprctl &>/dev/null; then
    # Reload hyprland config to pick up new colors
    hyprctl reload 2>/dev/null || true
    echo "   Hyprland config reloaded"
fi

echo ":: Theme reload complete!"
