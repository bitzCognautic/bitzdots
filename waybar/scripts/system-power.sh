#!/bin/bash

MENU_ITEMS=(
    "Lock"
    "Logout"
    "Sleep"
    "Reboot"
    "Shutdown"
    "Cancel"
)

ICONS_DIR="$HOME/.config/rofi/icons"
ITEMS=""
for item in "${MENU_ITEMS[@]}"; do
    icon_file="$ICONS_DIR/${item}.svg"
    if [ -f "$icon_file" ]; then
        ITEMS+="${item}\0icon\x1f${icon_file}\n"
    else
        ITEMS+="${item}\n"
    fi
done

choice=$(echo -e "$ITEMS" | rofi -dmenu -p "Power" -theme "$HOME/.config/rofi/themes/power.rasi")

case "$choice" in
    "Lock")     loginctl lock-session ;;
    "Logout")   hyprctl dispatch exit ;;
    "Sleep")    systemctl suspend ;;
    "Reboot")   systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
    *)          exit 0 ;;
esac
