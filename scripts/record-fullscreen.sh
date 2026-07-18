#!/usr/bin/env bash

DEBOUNCE_DIR="/tmp/record-fullscreen.debounce"
if ! mkdir "$DEBOUNCE_DIR" 2>/dev/null; then exit 0; fi
trap "rmdir '$DEBOUNCE_DIR' 2>/dev/null || true" EXIT

pgrep -x wf-recorder >/dev/null 2>&1 && exit 0

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

AUDIO="$(pactl get-default-sink 2>/dev/null).monitor"
OLD_VOL="$(pactl get-source-volume "$AUDIO" 2>/dev/null | grep -oP '\d+%' | head -1)"
pactl set-source-volume "$AUDIO" 200% 2>/dev/null || true
trap "pactl set-source-volume '$AUDIO' '$OLD_VOL' 2>/dev/null || true; rmdir '$DEBOUNCE_DIR' 2>/dev/null || true" EXIT

notify-send "Recording" "Fullscreen recording started"
if wf-recorder -f "$FILE" -a "$AUDIO"; then
    ffmpeg -i "$FILE" -af "volume=3.0" -c:v copy -c:a aac -b:a 192k "${FILE}.tmp" 2>/dev/null && mv "${FILE}.tmp" "$FILE"
    notify-send "Recording" "Fullscreen recording saved: $FILE"
fi
