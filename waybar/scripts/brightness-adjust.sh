#!/usr/bin/env bash
action="${1:-}"

set_brightnessctl() {
    local val="$1"
    if command -v brightnessctl &>/dev/null; then
        local dev
        dev=$(timeout 2 brightnessctl -l 2>/dev/null | grep -oP "'[^']+'" | head -1 | tr -d "'")
        if [ -n "$dev" ]; then
            brightnessctl -d "$dev" s "$val" &>/dev/null && return 0
        fi
        brightnessctl s "$val" &>/dev/null && return 0
    fi
    return 1
}

set_sysfs() {
    local dir
    dir=$(ls /sys/class/backlight/ 2>/dev/null | head -1)
    [ -z "$dir" ] && return 1

    local max
    max=$(cat "/sys/class/backlight/$dir/max_brightness" 2>/dev/null)
    [ -z "$max" ] && return 1

    local cur
    cur=$(cat "/sys/class/backlight/$dir/actual_brightness" 2>/dev/null)
    [ -z "$cur" ] && return 1

    local step=$(( max / 20 ))
    [ "$step" -lt 1 ] && step=1

    local new
    case "$action" in
        up|+*) new=$(( cur + step )) ;;
        down|-*) new=$(( cur - step )) ;;
        *) return 1 ;;
    esac

    [ "$new" -lt 0 ] && new=0
    [ "$new" -gt "$max" ] && new="$max"

    printf "%s" "$new" > "/sys/class/backlight/$dir/brightness" 2>/dev/null && return 0
    return 1
}

set_light() {
    command -v light &>/dev/null || return 1
    case "$action" in
        up|+*) light -A 5 &>/dev/null && return 0 ;;
        down|-*) light -U 5 &>/dev/null && return 0 ;;
    esac
    return 1
}

case "$action" in
    up|+*) act="+5%" ;;
    down|-*) act="5%-" ;;
    *) echo "Usage: $0 {up|down}"; exit 1 ;;
esac

set_brightnessctl "$act" || set_sysfs || set_light || exit 1
