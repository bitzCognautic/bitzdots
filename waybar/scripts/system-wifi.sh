#!/bin/bash

action=$(printf "Connect to network\nToggle WiFi\nOpen nmtui" | rofi -dmenu -p "WiFi" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')

case "$action" in
    "Connect to network")
        networks=$(nmcli -t -f SSID device wifi list 2>/dev/null | grep -v "^:" | sort -u)
        [ -z "$networks" ] && notify-send "No networks found" && exit 1
        ssid=$(echo "$networks" | rofi -dmenu -p "SSID" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')
        [ -z "$ssid" ] && exit 0
        kitty --class system-tui -e bash -c "nmcli device wifi connect '$ssid'; echo; echo 'Press Enter to exit'; read"
        ;;
    "Toggle WiFi")
        if nmcli radio wifi | grep -q "enabled"; then
            nmcli radio wifi off
            notify-send "WiFi turned off"
        else
            nmcli radio wifi on
            notify-send "WiFi turned on"
        fi
        ;;
    "Open nmtui")
        kitty --class system-tui -e nmtui
        ;;
esac
