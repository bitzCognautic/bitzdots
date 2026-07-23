#!/bin/bash
exec python3 -u -c "
import socket, os, sys, subprocess, errno

hypr_dir = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
runtime_dir = os.environ.get('XDG_RUNTIME_DIR')
if not hypr_dir or not runtime_dir:
    sys.exit(1)

sock_path = f'{runtime_dir}/hypr/{hypr_dir}/.socket2.sock'
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(sock_path)

events = {'workspace', 'focusedmon', 'movewindow', 'openwindow', 'closewindow'}

while True:
    try:
        data = sock.recv(4096)
        if not data:
            break
        for line in data.decode().split(chr(10)):
            if line and line.split('>>')[0] in events:
                subprocess.run(['pkill', '-RTMIN+1', '-x', 'waybar'],
                             capture_output=True)
    except socket.timeout:
        continue
    except OSError as e:
        if e.errno != errno.EINTR:
            break
"
