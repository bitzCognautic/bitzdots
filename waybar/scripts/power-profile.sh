#!/bin/bash
if command -v powerprofilesctl &>/dev/null && powerprofilesctl get &>/dev/null; then
    profile=$(powerprofilesctl get 2>/dev/null)
    case "$profile" in
        power-saver) icon="\udb80\udf2a" ;;
        balanced)    icon="\uf24e" ;;
        performance) icon="\uf427" ;;
        *)           icon="\uf24e" ;;
    esac
    echo "{\"text\":\"$icon\",\"class\":\"$profile\",\"tooltip\":\"Power profile: $profile\"}"
else
    echo '{"text":"","class":"","tooltip":""}'
fi
