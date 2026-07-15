#!/bin/bash
# Daemon: renames workspaces 1-5 to show state
# [1] = active, |2| = occupied, 3 = empty
# Runs in background, native waybar module displays the names

while true; do
    active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
    all=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' 2>/dev/null)
    clients=$(hyprctl clients -j 2>/dev/null | jq -r '.[].workspace.id' 2>/dev/null | sort -nu)

    for i in 1 2 3 4 5; do
        echo "$all" | grep -qx "$i" || continue
        if [ "$i" = "$active" ]; then
            hyprctl renameworkspace "$i" "[$i]" 2>/dev/null
        elif echo "$clients" | grep -qx "$i"; then
            hyprctl renameworkspace "$i" "|$i|" 2>/dev/null
        else
            hyprctl renameworkspace "$i" "$i" 2>/dev/null
        fi
    done
    sleep 1
done
