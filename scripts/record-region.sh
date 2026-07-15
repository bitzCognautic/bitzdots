#!/usr/bin/env bash
set -euo pipefail

# Screen recording — region selection with internal audio
# Created by opencode

DIR="$HOME/Videos/Recordings/Region"
mkdir -p "$DIR"

GEOM=$(slurp)
if [ -z "$GEOM" ]; then
    notify-send "Recording" "Cancelled"
    exit 1
fi

FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Region recording started"
wf-recorder -g "$GEOM" -f "$FILE" -a
notify-send "Recording" "Region recording saved: $FILE"
