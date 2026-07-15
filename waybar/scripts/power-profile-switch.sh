#!/bin/bash
if ! command -v powerprofilesctl &>/dev/null || ! powerprofilesctl get &>/dev/null; then
    notify-send "Power Profiles" "powerprofilesctl not available"
    exit 0
fi

current=$(powerprofilesctl get 2>/dev/null)
case "$current" in
    performance) next="power-saver" ;;
    power-saver) next="balanced" ;;
    balanced)    next="performance" ;;
    *)           next="balanced" ;;
esac

powerprofilesctl set "$next" 2>/dev/null && notify-send "Power Profile" "Switched to $next" || notify-send -u critical "Power Profile" "Failed to switch"
