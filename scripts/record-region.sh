#!/usr/bin/env bash

DEBOUNCE_DIR="/tmp/record-region.debounce"
if ! mkdir "$DEBOUNCE_DIR" 2>/dev/null; then exit 0; fi
trap "rmdir '$DEBOUNCE_DIR' 2>/dev/null || true" EXIT

pgrep -x wf-recorder >/dev/null 2>&1 && exit 0

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
