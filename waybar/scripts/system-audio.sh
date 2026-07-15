#!/bin/bash

action=$(printf "Switch output\nSwitch input\nOpen pulsemixer" | rofi -dmenu -p "Audio" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')

case "$action" in
    "Switch output")
        sinks=$(pactl list sinks short | awk '{print $2}' | rofi -dmenu -p "Output" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')
        [ -n "$sinks" ] && pactl set-default-sink "$sinks"
        ;;
    "Switch input")
        sources=$(pactl list sources short | awk '{print $2}' | rofi -dmenu -p "Input" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')
        [ -n "$sources" ] && pactl set-default-source "$sources"
        ;;
    "Open pulsemixer")
        if command -v pulsemixer &>/dev/null; then
            kitty --class system-tui -e pulsemixer
        elif command -v pavucontrol &>/dev/null; then
            pavucontrol
        fi
        ;;
esac
