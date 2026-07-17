#!/bin/bash
current=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"')
[ -z "$current" ] && notify-send "Power Profiles" "No power-profiles-daemon" && exit 0

case "$current" in
    performance) next="power-saver" ;;
    power-saver) next="balanced" ;;
    balanced)    next="performance" ;;
    *)           next="balanced" ;;
esac

busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "$next" 2>/dev/null &&
notify-send "Power Profile" "Switched to $next" ||
notify-send -u critical "Power Profile" "Failed to switch"
