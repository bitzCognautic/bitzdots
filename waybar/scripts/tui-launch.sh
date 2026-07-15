#!/usr/bin/env bash
TUI_CMD="$1"
FALLBACK="$2"

if command -v "$TUI_CMD" &>/dev/null; then
    kitty --class system-tui -e "$TUI_CMD"
else
    exec "$FALLBACK"
fi
