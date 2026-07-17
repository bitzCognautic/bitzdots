#!/bin/bash
if ! command -v powerprofilesctl &>/dev/null || ! powerprofilesctl get &>/dev/null; then
    notify-send "Power Profiles" "powerprofilesctl not available"
    exit 0
fi

profiles=$(powerprofilesctl list 2>/dev/null | grep -o '^  [a-z-]*' | tr -d ' ')
current=$(powerprofilesctl get 2>/dev/null)

next=""
found=0
for p in $profiles; do
    if [ "$found" = "1" ]; then
        next="$p"; break
    fi
    [ "$p" = "$current" ] && found=1
done
[ -z "$next" ] && next=$(echo "$profiles" | head -1)

powerprofilesctl set "$next" 2>/dev/null && notify-send "Power Profile" "$current → $next" || notify-send -u critical "Power Profile" "Failed to switch"
