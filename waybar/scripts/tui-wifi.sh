#!/usr/bin/env bash
# WiFi TUI — waits for NetworkManager to be ready so impala doesn't crash
# when opened right after boot.
set -u

NM_WAIT=15
WAIT_STEP=1

# If NetworkManager isn't up yet, wait for it (impala/nmcli crash otherwise)
waited=0
while ! nmcli -t -f STATE general 2>/dev/null | grep -q "connected\|connecting\|disconnected\|asleep\|unavailable"; do
    waited=$((waited + WAIT_STEP))
    if [ "$waited" -ge "$NM_WAIT" ]; then
        notify-send -u critical -t 4000 "WiFi TUI" "NetworkManager is not running" 2>/dev/null || true
        exit 1
    fi
    sleep "$WAIT_STEP"
done

# Make sure the radio is enabled
nmcli radio wifi on 2>/dev/null || true

if command -v impala &>/dev/null; then
    exec kitty --class system-tui -e impala
elif command -v nmtui &>/dev/null; then
    exec kitty --class system-tui -e nmtui
else
    notify-send -t 3000 "WiFi TUI" "Neither impala nor nmtui found" 2>/dev/null || true
    exit 1
fi
