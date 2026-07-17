#!/bin/bash
rfkill unblock bluetooth 2>/dev/null || true
exec kitty --class system-tui -e bluetui
