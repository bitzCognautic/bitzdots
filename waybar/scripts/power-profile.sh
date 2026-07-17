#!/bin/bash
profile=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"')
if [ -n "$profile" ]; then
    case "$profile" in
        power-saver) icon="\udb80\udf2a" ;;
        balanced)    icon="\uf24e" ;;
        performance) icon="\uf427" ;;
        *)           icon="\uf24e" ;;
    esac
    echo "{\"text\":\"$icon\",\"class\":\"$profile\",\"tooltip\":\"$profile\"}"
else
    echo '{"text":"","class":"","tooltip":""}'
fi
