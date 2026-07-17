#!/bin/bash
dir="$1"
status=$(playerctl status 2>/dev/null)
if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    [ "$dir" = "prev" ] && icon="󰒮" || icon="󰒭"
    echo "{\"text\":\"$icon\",\"class\":\"$status\"}"
else
    echo '{"text":"","class":"stopped"}'
fi
