#!/bin/bash
rfkill unblock bluetooth 2>/dev/null || true
if command -v bluetui &>/dev/null; then
    exec kitty --class system-tui -e bash -c "bluetui; echo; echo 'bluetui exited (code: \$?)'; echo 'Press Enter to close'; read"
else
    notify-send -t 3000 "Bluetooth TUI" "bluetui not found, opening bluetoothctl" 2>/dev/null || true
    exec kitty --class system-tui -e bash -c "bluetoothctl; echo; echo 'Press Enter to close'; read"
fi
