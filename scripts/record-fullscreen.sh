#!/usr/bin/env bash

DEBOUNCE_DIR="/tmp/record-fullscreen.debounce"
PID_FILE="/tmp/wf-recorder-fullscreen.pid"

# Atomic debounce: only one instance from a keypress gets through
if ! mkdir "$DEBOUNCE_DIR" 2>/dev/null; then exit 0; fi
trap "rmdir '$DEBOUNCE_DIR' 2>/dev/null || true" EXIT

# Clean stale PID from previous crash
[ -f "$PID_FILE" ] && ! kill -0 $(cat "$PID_FILE") 2>/dev/null && rm -f "$PID_FILE"

# Toggle: if a script instance is alive, stop recording
if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    pgrep -x wf-recorder >/dev/null 2>&1 && pkill -x wf-recorder 2>/dev/null && notify-send "Recording" "Stopped"
    exit 0
fi

# Start recording
rm -f "$PID_FILE"
echo $$ > "$PID_FILE"
trap "rm -f '$PID_FILE'; rmdir '$DEBOUNCE_DIR' 2>/dev/null || true" EXIT

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
AUDIO="$(pactl get-default-sink 2>/dev/null).monitor"
wf-recorder -f "$FILE" -a "$AUDIO" && notify-send "Recording" "Fullscreen recording saved: $FILE"
