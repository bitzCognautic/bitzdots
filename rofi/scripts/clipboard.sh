#!/bin/bash
# Rofi clipboard manager using cliphist

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
ROFI_THEME="$CONFIG_DIR/rofi/themes/launcher.rasi"

if ! command -v cliphist &>/dev/null; then
    notify-send -u critical "cliphist not installed"
    exit 1
fi

if ! pgrep -f "cliphist store" > /dev/null; then
    wl-paste --watch cliphist store &
    sleep 0.5
fi

if ! entries=$(cliphist list 2>/dev/null); then
    notify-send -u critical "cliphist error" "Failed to read clipboard history"
    exit 1
fi

if [ -z "$entries" ]; then
    notify-send -u normal "Clipboard empty" "Copy something first, then use Super+V"
    exit 0
fi

selected=$(
    echo "$entries" | rofi -dmenu -i -p "" -theme "$ROFI_THEME" \
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
