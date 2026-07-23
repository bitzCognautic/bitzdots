#!/bin/bash
exec python3 -u -c "
import json, os, socket, subprocess, sys

def get_workspaces():
    try:
        data = subprocess.run(['hyprctl', 'workspaces', '-j'], capture_output=True, text=True, timeout=2)
        ws = json.loads(data.stdout)
    except:
        return

    active = next((w['id'] for w in ws if w.get('focused')), 1)
    occupied = {w['id'] for w in ws if w.get('windows', 0) > 0}

    start = (active - 1) // 5 * 5 + 1
    end = start + 4

    parts = []
    for i in range(start, end + 1):
        if i == active:
            parts.append(f\"<span foreground='#FDF9EB' weight='bold'> [{i}] </span>\")
        elif i in occupied:
            parts.append(f\"<span foreground='#BBB394'> |{i}| </span>\")
        else:
            parts.append(f\"  {i}  \")

    result = {'text': ''.join(parts), 'class': 'workspaces', 'alt': str(active)}
    sys.stdout.write(json.dumps(result) + '\n')
    sys.stdout.flush()

# Initial output
get_workspaces()

# Listen to Hyprland event socket
hypr_dir = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
runtime_dir = os.environ.get('XDG_RUNTIME_DIR')
if not hypr_dir or not runtime_dir:
    sys.exit(1)

sock_path = f'{runtime_dir}/hypr/{hypr_dir}/.socket2.sock'
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(sock_path)

events = {'workspace', 'focusedmon', 'movewindow', 'openwindow', 'closewindow', 'changefloatingmode', 'destroyworkspace', 'createworkspace'}

while True:
    data = sock.recv(4096)
    if not data:
        break
    for line in data.decode().split('\n'):
        if line and line.split('>>')[0] in events:
            get_workspaces()
"
