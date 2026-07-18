#!/usr/bin/env bash
set -euo pipefail

LOCK_FILE="/tmp/record-fullscreen.lock"
PID_FILE="/tmp/wf-recorder-fullscreen.pid"

exec 200>"$LOCK_FILE"
flock 200

if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    kill $(cat "$PID_FILE") 2>/dev/null || true
    rm -f "$PID_FILE"
    notify-send "Recording" "Stopped"
    exit 0
fi

rm -f "$PID_FILE"
DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
wf-recorder -f "$FILE" -a &
PID=$!
echo $PID > "$PID_FILE"

flock -u 200

wait $PID || true
if [ -f "$PID_FILE" ]; then
    rm -f "$PID_FILE"
    notify-send "Recording" "Fullscreen recording saved: $FILE"
fi
