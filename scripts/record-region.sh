#!/usr/bin/env bash
set -euo pipefail

# Kill any existing recording first
if pgrep -x wf-recorder > /dev/null 2>&1; then
    pkill -x wf-recorder
    notify-send "Recording" "Stopped"
    exit 0
fi

DIR="$HOME/Videos/Recordings/Region"
mkdir -p "$DIR"
GEOM=$(slurp)

if [ -z "$GEOM" ]; then
    notify-send "Recording" "Cancelled"
    exit 1
fi

FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Region recording started"
wf-recorder -g "$GEOM" -f "$FILE" -a && notify-send "Recording" "Region recording saved: $FILE"
