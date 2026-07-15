#!/bin/bash

action=$(printf "Open btop\nOpen htop" | rofi -dmenu -p "System Monitor" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')

case "$action" in
    "Open btop")
        kitty --class system-tui -e btop
        ;;
    "Open htop")
        kitty --class system-tui -e htop
        ;;
esac
