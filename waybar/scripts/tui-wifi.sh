#!/usr/bin/env bash
if command -v impala &>/dev/null; then
    exec kitty --class system-tui -e impala
elif command -v nmtui &>/dev/null; then
    exec kitty --class system-tui -e nmtui
else
    notify-send -t 3000 "WiFi TUI" "Neither impala nor nmtui found" 2>/dev/null || true
    exit 1
fi
