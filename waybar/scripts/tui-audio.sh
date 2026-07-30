#!/usr/bin/env bash
if command -v pulsemixer &>/dev/null; then
    exec kitty --class system-tui -e pulsemixer
elif command -v pavucontrol &>/dev/null; then
    exec pavucontrol
else
    notify-send -t 3000 "Audio TUI" "Neither pulsemixer nor pavucontrol found" 2>/dev/null || true
    exit 1
fi
