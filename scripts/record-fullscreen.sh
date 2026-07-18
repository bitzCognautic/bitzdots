#!/usr/bin/env bash

LOCKDIR="/tmp/record-fullscreen.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
    pkill -x wf-recorder 2>/dev/null && notify-send "Recording" "Stopped"
    exit 0
fi
trap "rmdir '$LOCKDIR' 2>/dev/null || true" EXIT

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
wf-recorder -f "$FILE" < /dev/null && notify-send "Recording" "Fullscreen recording saved: $FILE"
