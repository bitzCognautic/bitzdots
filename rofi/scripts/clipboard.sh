#!/bin/bash
# Rofi clipboard manager using cliphist
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
ROFI_THEME="$CONFIG_DIR/rofi/themes/launcher.rasi"

if ! command -v cliphist &>/dev/null; then
    notify-send -u critical "cliphist not installed"
    exit 1
fi

# Ensure cliphist store daemon is running
if ! pgrep -f "cliphist store" > /dev/null; then
    wl-paste --watch cliphist store &
    sleep 0.5
fi

# Check if there are any entries
if ! cliphist list 2>/dev/null | grep -q .; then
    notify-send -u normal "Clipboard empty" "Copy something first, then use Super+V"
    exit 0
fi

selected=$(
    cliphist list | rofi -dmenu -i -p "" -theme "$ROFI_THEME" \
        -theme-str 'listview { columns: 1; lines: 10; } entry { placeholder: ""; }'
)

if [ -z "$selected" ]; then
    exit 0
fi

item_id=$(echo "$selected" | cut -d'	' -f1)

if [ -z "$item_id" ]; then
    exit 0
fi

cliphist decode "$item_id" | wl-copy
notify-send "Clipboard" "Item #$item_id copied"
