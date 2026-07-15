#!/bin/bash
if rfkill list bluetooth | grep -q "Soft blocked: no"; then
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo true
    else
        echo false
    fi
else
    echo false
fi
