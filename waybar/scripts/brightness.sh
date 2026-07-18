#!/usr/bin/env bash

current=$(timeout 2 brightnessctl g 2>/dev/null)
max=$(timeout 2 brightnessctl m 2>/dev/null)
[ -z "$max" ] && max=255

pct=$(( current * 100 / max ))

if [ "$pct" -ge 80 ]; then
    icon="󰃠"
elif [ "$pct" -ge 50 ]; then
    icon="󰃟"
elif [ "$pct" -ge 20 ]; then
    icon="󰃝"
else
    icon="󰃜"
fi

printf '{"text":"%s %s%%","tooltip":"Brightness: %s%%","class":""}\n' \
    "$icon" "$pct" "$pct"
