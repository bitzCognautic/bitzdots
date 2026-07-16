#!/usr/bin/env bash
if pgrep -x wf-recorder > /dev/null 2>&1; then
    COUNTER=$(cat /tmp/waybar-recording-blink 2>/dev/null || echo 0)
    COUNTER=$(( (COUNTER + 1) % 2 ))
    echo "$COUNTER" > /tmp/waybar-recording-blink
    if [ "$COUNTER" -eq 0 ]; then
        echo '{"text": "  ", "class": "recording", "tooltip": "Recording in progress"}'
    else
        echo '{"text": "", "class": "recording", "tooltip": "Recording in progress"}'
    fi
else
    echo '{"text": "", "class": "idle"}'
fi
