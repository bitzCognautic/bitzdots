#!/bin/bash
eval "$(hyprctl workspaces -j 2>/dev/null | jq -r '
  .[] | select(.focused == true) | .id as $a |
  [.[] | select(.windows > 0) | .id] as $o |
  "active=\($a)\noccupied=\($o | join(" "))"
' 2>/dev/null)"

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
        text+="<span foreground='$color_empty'>  ${i}  </span>"
    fi
done

jq -cn --arg text "$text" --arg alt "$active" '{text: $text, class: "workspaces", alt: $alt}'
