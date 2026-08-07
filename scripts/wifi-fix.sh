#!/bin/bash
# Wait for NetworkManager to be ready and ensure WiFi auto-connects.
# Fixes: on boot WiFi sometimes shows disconnected (strikethrough) and
#        impala/nmtui crash because NetworkManager isn't up yet.
set -u

NM_WAIT=30          # max seconds to wait for NetworkManager
CONN_WAIT=45        # max seconds to wait for an active connection
WAIT_STEP=1

log() { echo "[wifi-fix] $*"; }

# 1. Wait for NetworkManager D-Bus to come up
waited=0
while ! nmcli -t -f STATE general 2>/dev/null | grep -q "connected\|connecting\|disconnected\|asleep\|unavailable"; do
    waited=$((waited + WAIT_STEP))
    if [ "$waited" -ge "$NM_WAIT" ]; then
        log "NetworkManager did not come up after ${NM_WAIT}s"
        exit 1
    fi
    sleep "$WAIT_STEP"
done
log "NetworkManager is up"

# 2. Make sure the radio is not soft-blocked
if command -v rfkill &>/dev/null; then
    rfkill unblock wifi 2>/dev/null || true
fi

# 3. Ensure WiFi radio is on
nmcli radio wifi on 2>/dev/null || true

# 4. Let NetworkManager autoconnect to saved profiles. If it already
#    connected during boot, skip; otherwise retry each saved connection.
if nmcli -t -f DEVICE,STATE dev status 2>/dev/null | grep -q ":connected"; then
    log "Already connected"
    exit 0
fi

for _ in $(seq 1 "$CONN_WAIT"); do
    if nmcli -t -f DEVICE,STATE dev status 2>/dev/null | grep -q ":connected"; then
        log "Connected"
        exit 0
    fi
    sleep "$WAIT_STEP"
done

# Still not connected — explicitly activate every saved connection once
log "Not connected yet — reactivating saved connections"
while IFS=: read -r name uuid; do
    [ -n "$name" ] || continue
    log "Connecting to $name"
    nmcli connection up uuid "$uuid" 2>/dev/null
done < <(nmcli -t -f NAME,UUID connection show 2>/dev/null)

sleep 3
if nmcli -t -f DEVICE,STATE dev status 2>/dev/null | grep -q ":connected"; then
    log "Connected after reactivation"
    exit 0
fi

# If still offline, retry a couple more times with a short delay
for attempt in 1 2 3; do
    sleep 5
    nmcli radio wifi off 2>/dev/null
    sleep 2
    nmcli radio wifi on 2>/dev/null
    for _ in $(seq 1 10); do
        if nmcli -t -f DEVICE,STATE dev status 2>/dev/null | grep -q ":connected"; then
            log "Connected after retry"
            exit 0
        fi
        sleep 1
    done
done

log "Could not connect to any network (attempt $attempt/3)"
exit 1
