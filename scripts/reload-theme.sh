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

# --- Hyprland: reload config to pick up new colors ---
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null || true
    echo "   Hyprland config reloaded"
fi

echo ":: Theme reload complete!"
