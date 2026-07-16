#!/usr/bin/env bash

dnd=$(swaync-client -D)
count=$(swaync-client -c)

if [ "$dnd" = "true" ]; then
    class="dnd"
    icon="󰂛"
elif [ "$count" -gt 0 ]; then
    class="has"
    icon="󰂚"
else
    class="none"
    icon="󰂚"
fi

printf '{"text":"%s","class":"%s","tooltip":"Notifications%s"}\n' \
    "$icon" "$class" "$([ "$dnd" = "true" ] && echo ' (DND)')"
