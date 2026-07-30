#!/usr/bin/env bash

dnd=$(swaync-client -D 2>/dev/null) || true
count=$(swaync-client -c 2>/dev/null) || true

if [ -z "$dnd" ]; then
    printf '{"text":"󰂛","class":"dnd","tooltip":"Notifications (unavailable)"}\n'
    exit 0
fi

if [ "$dnd" = "true" ]; then
    class="dnd"
    icon="󰂛"
elif [ "$count" -gt 0 ] 2>/dev/null; then
    class="has"
    icon="󰂚"
else
    class="none"
    icon="󰂚"
fi

printf '{"text":"%s","class":"%s","tooltip":"Notifications%s"}\n' \
    "$icon" "$class" "$([ "$dnd" = "true" ] && echo ' (DND)')"
