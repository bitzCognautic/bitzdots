#!/bin/bash
if command -v powerprofilesctl &>/dev/null && powerprofilesctl get &>/dev/null; then
    profile=$(powerprofilesctl get 2>/dev/null)
    case "$profile" in
        performance) icon="\uf21e" ;;
        balanced)    icon="\uf0e7" ;;
        power-saver) icon="\uf2e8" ;;
        *)           icon="\uf0e7" ;;
    esac
    echo "{\"text\":\"$icon\",\"class\":\"$profile\",\"tooltip\":\"Power profile: $profile\"}"
else
    echo '{"text":"","class":"","tooltip":""}'
fi
