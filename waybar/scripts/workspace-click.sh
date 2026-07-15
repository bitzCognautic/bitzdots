#!/bin/bash
# Determine which workspace was clicked based on horizontal pixel position
# Works with workspaces.sh pixel-offset cache
# Waybar sets $XREL env var (pixel offset relative to module origin)

cache_file="/tmp/waybar-ws-cache"
XREL="${XREL:-0}"

target=""
while IFS=: read -r offset ws; do
    if [ "$XREL" -ge "$offset" ]; then
        target="$ws"
    fi
done < "$cache_file"

if [ -n "$target" ]; then
    hyprctl dispatch 'hl.dsp.focus({workspace = "'"$target"'"})'
fi
