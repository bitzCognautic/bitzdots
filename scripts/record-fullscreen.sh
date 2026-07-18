#!/usr/bin/env bash

DEBOUNCE_DIR="/tmp/record-fullscreen.debounce"
if ! mkdir "$DEBOUNCE_DIR" 2>/dev/null; then exit 0; fi
trap "rmdir '$DEBOUNCE_DIR' 2>/dev/null || true" EXIT

pgrep -x wf-recorder >/dev/null 2>&1 && exit 0

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
AUDIO="$(pactl get-default-sink 2>/dev/null).monitor"
wf-recorder -f "$FILE" -a "$AUDIO" && notify-send "Recording" "Fullscreen recording saved: $FILE"
