#!/bin/bash

action=$(printf "Toggle Bluetooth\nConnect device\nOpen bluetoothctl" | rofi -dmenu -p "Bluetooth" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')

case "$action" in
    "Toggle Bluetooth")
        if bluetoothctl show | grep -q "Powered: yes"; then
            bluetoothctl power off
            notify-send "Bluetooth turned off"
        else
            bluetoothctl power on
            notify-send "Bluetooth turned on"
        fi
        ;;
    "Connect device")
        devices=$(bluetoothctl devices | awk '{$1=""; $2=""; print substr($0,3)}')
        [ -z "$devices" ] && notify-send "No paired devices" && exit 1
        device=$(echo "$devices" | rofi -dmenu -p "Device" -theme-str 'window {border-radius: 0;} listview {border-radius: 0;}')
        [ -z "$device" ] && exit 0
        mac=$(bluetoothctl devices | grep "$device" | awk '{print $2}')
        kitty --class system-tui -e bash -c "bluetoothctl connect '$mac'; echo; echo 'Press Enter to exit'; read"
        ;;
    "Open bluetoothctl")
        kitty --class system-tui -e bash -c "bluetoothctl; echo 'Press Enter to exit'; read"
        ;;
esac
