#!/usr/bin/env bash

LOCKDIR="/tmp/record-region.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
    pkill -x wf-recorder 2>/dev/null && notify-send "Recording" "Stopped"
    rmdir "$LOCKDIR" 2>/dev/null || true
    exit 0
fi
trap "rmdir '$LOCKDIR' 2>/dev/null || true" EXIT

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
wf-recorder -g "$GEOM" -f "$FILE" -a "$AUDIO" <&- && notify-send "Recording" "Region recording saved: $FILE"
