#!/bin/bash
current=$(busctl get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"')
[ -z "$current" ] && exit 0

profiles=$(busctl get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles Profiles 2>/dev/null | grep -oP '"Profile" s "\K[^"]+')
[ -z "$profiles" ] && exit 0

next=""
found=0
for p in $profiles; do
    if [ "$found" = "1" ]; then
        next="$p"; break
    fi
    [ "$p" = "$current" ] && found=1
done
[ -z "$next" ] && next=$(echo "$profiles" | head -1)

busctl set-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles ActiveProfile s "$next" 2>/dev/null && notify-send "Power Profile" "$current → $next" || notify-send -u critical "Power Profile" "Failed to switch"
