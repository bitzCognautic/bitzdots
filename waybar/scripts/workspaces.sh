#!/bin/bash
data=$(hyprctl workspaces -j 2>/dev/null)
active=$(echo "$data" | jq -r '.[] | select(.focused == true) | .id' 2>/dev/null)
occupied=$(echo "$data" | jq -r '.[] | select(.windows > 0) | .id' 2>/dev/null | tr '\n' ' ')
[ -z "$active" ] && active=1

start=$(( (active - 1) / 5 * 5 + 1 ))
end=$(( start + 4 ))

text=""
for (( i = start; i <= end; i++ )); do
    if [ "$i" = "$active" ]; then
        text+="<span foreground='#FDF9EB' weight='bold'> [${i}] </span>"
    elif [[ " $occupied " == *" $i "* ]]; then
        text+="<span foreground='#BBB394'> |${i}| </span>"
    else
        text+="  ${i}  "
    fi
done

printf '{"text":"%s","class":"workspaces","alt":"%s"}\n' "$text" "$active"
