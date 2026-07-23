#!/bin/bash
data=$(hyprctl workspaces -j 2>/dev/null)
active=$(echo "$data" | jq -r '.[] | select(.focused == true) | .id' 2>/dev/null)
occupied=$(echo "$data" | jq -r '.[] | select(.windows > 0) | .id' 2>/dev/null | tr '\n' ' ')

[ -z "$active" ] && active=1

color_active="#${WALLUST_FG:-FDF9EB}"
color_occupied="#${WALLUST_COLOR6:-BBB394}"
color_empty="#${WALLUST_COLOR8:-AAA798}"

start=$(( (active - 1) / 5 * 5 + 1 ))
end=$(( start + 4 ))

text=""
for (( i = start; i <= end; i++ )); do
    if [ "$i" = "$active" ]; then
        text+="<span foreground='$color_active' weight='bold'> [${i}] </span>"
    elif [[ " $occupied " == *" $i "* ]]; then
        text+="<span foreground='$color_occupied'> |${i}| </span>"
    else
        text+="  ${i}  "
    fi
done

printf '{"text":"%s","class":"workspaces","alt":"%s"}\n' "$text" "$active"
