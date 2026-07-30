#!/bin/bash
rfkill unblock bluetooth 2>/dev/null || true
if command -v bluetui &>/dev/null; then
    exec kitty --class system-tui -e bluetui
else
    notify-send -t 3000 "Bluetooth TUI" "bluetui not found, opening bluetoothctl" 2>/dev/null || true
    exec kitty --class system-tui -e bash -c "bluetoothctl; echo 'Press Enter to exit'; read"
fi
