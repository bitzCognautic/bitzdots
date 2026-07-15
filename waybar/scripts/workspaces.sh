#!/bin/bash
# Output workspace state as formatted text for Waybar custom/workspaces
# Fixed-width columns (5 chars each) for horizontal position tracking
# Writes pixel-offset cache for workspace-click.sh

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
if [ -f "$CONFIG_DIR/wallust/env" ]; then
    source "$CONFIG_DIR/wallust/env"
fi

active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
clients=$(hyprctl clients -j 2>/dev/null | jq -r '.[].workspace.id' | sort -nu)

color_active="#${WALLUST_FG:-FDF9EB}"
color_occupied="#${WALLUST_COLOR6:-BBB394}"
color_empty="#${WALLUST_COLOR8:-AAA798}"

start=$(( (active - 1) / 5 * 5 + 1 ))
end=$(( start + 4 ))
CELL_W=5
FONT_SIZE=12
# Approximate pixel width per character for monospace font
CHAR_W=$(awk "BEGIN { printf \"%.2f\", $FONT_SIZE * 0.6 }" 2>/dev/null || echo 7.2)
CELL_PX=$(awk "BEGIN { printf \"%d\", $CELL_W * $CHAR_W }" 2>/dev/null || echo 36)

text=""
px_offset=0
cache_file="/tmp/waybar-ws-cache"
> "$cache_file"

for i in $(seq "$start" "$end"); do
    if [ "$i" = "$active" ]; then
        entry="[${i}]"
        item="<span foreground='$color_active' weight='bold'>"
    elif echo "$clients" | grep -qx "$i"; then
        entry="|${i}|"
        item="<span foreground='$color_occupied'>"
    else
        entry=" ${i} "
        item="<span foreground='$color_empty'>"
    fi

    while [ ${#entry} -lt $CELL_W ]; do
        entry="$entry "
    done

    echo "$px_offset:$i" >> "$cache_file"
    text="${text}${item}${entry}</span>"
    px_offset=$((px_offset + CELL_PX))
done

echo "{\"text\":\"$text\",\"class\":\"workspaces\",\"alt\":\"$active\"}"
