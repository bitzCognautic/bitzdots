#!/usr/bin/env bash

PID_FILE="/tmp/wf-recorder-region.pid"

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

DIR="$HOME/Videos/Recordings/Region"
mkdir -p "$DIR"
GEOM=$(slurp)

if [ -z "$GEOM" ]; then
    notify-send "Recording" "Cancelled"
    exit 1
fi

FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Region recording started"
AUDIO="$(pactl get-default-sink 2>/dev/null).monitor"
wf-recorder -g "$GEOM" -f "$FILE" -a "$AUDIO" && notify-send "Recording" "Region recording saved: $FILE"
