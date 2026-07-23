#!/bin/bash
# Monitors Hyprland workspace events and signals waybar for instant updates
python3 -c "
import socket, os, signal, sys

hypr_dir = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
runtime_dir = os.environ.get('XDG_RUNTIME_DIR')
if not hypr_dir or not runtime_dir:
    sys.exit(1)

sock_path = f'{runtime_dir}/hypr/{hypr_dir}/.socket2.sock'
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    sock.connect(sock_path)
except:
    sys.exit(1)

events = set([
    'workspace', 'focusedmon', 'movewindow', 'openwindow',
    'closewindow', 'changefloatingmode', 'destroyworkspace', 'createworkspace'
])

while True:
    data = sock.recv(4096)
    if not data:
        break
    for line in data.decode().split('\n'):
        if line and line.split('>>')[0] in events:
            os.system('pkill -RTMIN+1 -x waybar 2>/dev/null || true')
"
