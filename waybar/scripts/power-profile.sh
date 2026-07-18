#!/bin/bash
profile=$(busctl get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"')
if [ -z "$profile" ]; then
    echo '{"text":"","class":"","tooltip":""}'
    exit 0
fi
case "$profile" in
    power-saver) icon="\udb80\udf2a" ;;
    balanced)    icon="\uf24e" ;;
    performance) icon="\uf427" ;;
    *)           icon="\uf24e" ;;
esac
echo "{\"text\":\"$icon\",\"class\":\"$profile\",\"tooltip\":\"$profile\"}"
