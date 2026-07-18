#!/usr/bin/env bash
set -euo pipefail

PID_FILE="/tmp/wf-recorder-region.pid"

if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    kill $(cat "$PID_FILE") 2>/dev/null || true
    rm -f "$PID_FILE"
    notify-send "Recording" "Stopped"
    exit 0
fi

rm -f "$PID_FILE"
DIR="$HOME/Videos/Recordings/Region"
mkdir -p "$DIR"
GEOM=$(slurp)

if [ -z "$GEOM" ]; then
    notify-send "Recording" "Cancelled"
    exit 1
fi

FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Region recording started"
wf-recorder -g "$GEOM" -f "$FILE" -a &
PID=$!
echo $PID > "$PID_FILE"

wait $PID || true
if [ -f "$PID_FILE" ]; then
    rm -f "$PID_FILE"
    notify-send "Recording" "Region recording saved: $FILE"
fi
