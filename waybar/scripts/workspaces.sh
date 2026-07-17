#!/bin/bash
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
[ -f "$CONFIG_DIR/wallust/env" ] && source "$CONFIG_DIR/wallust/env"

generate_state() {
    active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
    clients=$(hyprctl clients -j 2>/dev/null | jq -r '.[].workspace.id' | sort -nu)

    color_active="#${WALLUST_FG:-FDF9EB}"
    color_occupied="#${WALLUST_COLOR6:-BBB394}"
    color_empty="#${WALLUST_COLOR8:-AAA798}"

    start=$(( (active - 1) / 5 * 5 + 1 ))
    end=$(( start + 4 ))
    CELL_W=5
    FONT_SIZE=12
    CHAR_W=$(awk "BEGIN { printf \"%.2f\", $FONT_SIZE * 0.6 }" 2>/dev/null || echo 7.2)
    CELL_PX=$(awk "BEGIN { printf \"%d\", $CELL_W * $CHAR_W }" 2>/dev/null || echo 36)

    text=""
    px_offset=0
    cache_file="/tmp/waybar-ws-cache"
    > "$cache_file"

    for i in $(seq "$start" "$end"); do
        if [ "$i" = "$active" ]; then
            entry="[${i}]"
            item="<span foreground='$color_active' weight='bold'>"
        elif echo "$clients" | grep -qx "$i"; then
            entry="|${i}|"
            item="<span foreground='$color_occupied'>"
        else
            entry=" ${i} "
            item="<span foreground='$color_empty'>"
        fi

        while [ ${#entry} -lt $CELL_W ]; do
            entry="$entry "
        done

        echo "$px_offset:$i" >> "$cache_file"
        text="${text}${item}${entry}</span>"
        px_offset=$((px_offset + CELL_PX))
    done

    echo "{\"text\":\"$text\",\"class\":\"workspaces\",\"alt\":\"$active\"}"
}

generate_state

HYPRDIR="$XDG_RUNTIME_DIR/hypr"
INSTANCE="${HYPRLAND_INSTANCE_SIGNATURE:-$(ls -1 "$HYPRDIR" 2>/dev/null | head -1)}"
socket="$HYPRDIR/$INSTANCE/.socket2.sock"
[ ! -S "$socket" ] && exit 0

while read -r _; do
    generate_state
done < <(
    python3 -u -c "
import socket, sys
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    s.connect('$socket')
except Exception:
    sys.exit(0)
buf = ''
while True:
    try:
        data = s.recv(4096)
    except Exception:
        break
    if not data:
        break
    buf += data.decode()
    while '\n' in buf:
        line, buf = buf.split('\n', 1)
        event = line.split('>>')[0]
        if event in ('workspace', 'focusedmon', 'openwindow', 'closewindow', 'movewindow', 'createworkspace', 'destroyworkspace'):
            sys.stdout.write('x\n')
            sys.stdout.flush()
"
)
