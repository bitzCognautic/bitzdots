#!/usr/bin/env bash
set -euo pipefail

# Kill any existing recording first
if pgrep -x wf-recorder > /dev/null 2>&1; then
    pkill -x wf-recorder
    notify-send "Recording" "Stopped"
    exit 0
fi

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"
FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
wf-recorder -f "$FILE" -a && notify-send "Recording" "Fullscreen recording saved: $FILE"
