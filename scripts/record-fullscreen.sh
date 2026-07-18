#!/usr/bin/env bash

DEBOUNCE_DIR="/tmp/record-fullscreen.debounce"
if ! mkdir "$DEBOUNCE_DIR" 2>/dev/null; then exit 0; fi
(sleep 0.2 && rmdir "$DEBOUNCE_DIR" 2>/dev/null || true) &

PID_FILE="/tmp/wf-recorder-fullscreen.pid"

[ -f "$PID_FILE" ] && ! kill -0 $(cat "$PID_FILE") 2>/dev/null && rm -f "$PID_FILE"

if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    if pgrep -x wf-recorder >/dev/null 2>&1; then
        pkill -x wf-recorder 2>/dev/null || true
        notify-send "Recording" "Stopped"
    fi
    exit 0
fi

rm -f "$PID_FILE"
echo $$ > "$PID_FILE"
trap "rm -f '$PID_FILE'" EXIT

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
AUDIO="$(pactl get-default-sink 2>/dev/null).monitor"
wf-recorder -f "$FILE" -a "$AUDIO" && notify-send "Recording" "Fullscreen recording saved: $FILE"
