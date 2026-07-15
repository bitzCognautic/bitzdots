#!/usr/bin/env bash

CACHE="$HOME/.cache/waybar-weather.json"
CACHE_TTL=1800

if [ -f "$CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -lt $CACHE_TTL ]; then
    cat "$CACHE"
    exit 0
fi

data=$(curl -sf "https://wttr.in?format=%c+%t" 2>/dev/null)
if [ -n "$data" ]; then
    # Remove leading + from temperature and format as JSON
    temp=$(echo "$data" | sed 's/[+ ]//g' | sed 's/ //g')
    class=""
    echo "{\"text\":\"\uf7b2 $temp\",\"class\":\"$class\",\"tooltip\":\"$data\"}" | tee "$CACHE"
else
    if [ -f "$CACHE" ]; then
        cat "$CACHE"
    else
        echo '{"text":" --","class":"","tooltip":"No data"}'
    fi
fi
