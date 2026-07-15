#!/usr/bin/env bash
set -euo pipefail

# Screen recording — fullscreen with internal audio
# Created by opencode

DIR="$HOME/Videos/Recordings/Fullscreen"
mkdir -p "$DIR"

FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

notify-send "Recording" "Fullscreen recording started"
wf-recorder -f "$FILE" -a
notify-send "Recording" "Fullscreen recording saved: $FILE"
