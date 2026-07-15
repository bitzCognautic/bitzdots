#!/bin/bash
# Output workspace state as JSON array for Eww
# Shows batches of 5 based on active workspace

active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
clients=$(hyprctl clients -j 2>/dev/null | jq -r '.[].workspace.id' | sort -nu)

# Determine batch (groups of 5)
start=$(( (active - 1) / 5 * 5 + 1 ))
end=$(( start + 4 ))

items=""
sep=""
for i in $(seq "$start" "$end"); do
    if [ "$i" = "$active" ]; then
        display="[$i]"
        cls="active"
    elif echo "$clients" | grep -qx "$i"; then
        display="|$i|"
        cls="occupied"
    else
        display="$i"
        cls="empty"
    fi
    items="${items}${sep}{\"id\":$i,\"display\":\"$display\",\"class\":\"$cls\",\"onclick\":\"hyprctl dispatch 'hl.dsp.focus({workspace = $i})'\"}"
    sep=","
done

echo "[$items]"
