# Keybindings

All 55+ keybindings are defined in `hypr/keybinds.lua` using Hyprland's Lua API. Modifiers:

- `SUPER` = Windows/Command key
- `SHIFT` = Shift key
- `CTRL` = Control key
- `ALT` = Alt key

## Window Management

| Key | Action |
|-----|--------|
| `SUPER`+`Q` | Close active window |
| `SUPER`+`F` | Toggle fullscreen |
| `SUPER`+`H` | Toggle window float |
| `SUPER`+`CTRL`+`F` | Toggle window float (alternate) |
| `SUPER`+`mouse:272` | Move window (mouse drag) |
| `SUPER`+`mouse:273` | Resize window (mouse drag) |
| `SUPER`+`CTRL`+`R` | Enter resize submode |

### Resize Submode

Activate with `SUPER`+`CTRL`+`R`, then:

| Key | Action |
|-----|--------|
| `Left` | Resize window left by 10px |
| `Right` | Resize window right by 10px |
| `Up` | Resize window up by 10px |
| `Down` | Resize window down by 10px |
| `Escape` | Exit resize mode |
| `SUPER`+`CTRL`+`R` | Exit resize mode |

## Workspaces

| Key | Action |
|-----|--------|
| `SUPER`+`1-9` | Focus workspace 1-9 |
| `SUPER`+`0` | Focus workspace 10 |
| `SUPER`+`SHIFT`+`1-9` | Move window to workspace 1-9 |
| `SUPER`+`SHIFT`+`0` | Move window to workspace 10 |
| `SUPER`+`mouse_down` | Next workspace |
| `SUPER`+`mouse_up` | Previous workspace |
| `SUPER`+`ALT`+`mouse_down` | Move window to next workspace |
| `SUPER`+`ALT`+`mouse_up` | Move window to previous workspace |
| `SUPER`+`SHIFT`+`mouse_down` | Move window to next workspace |
| `SUPER`+`SHIFT`+`mouse_up` | Move window to previous workspace |

## Applications

| Key | Action |
|-----|--------|
| `SUPER`+`T` | Open terminal (kitty) |
| `SUPER`+`E` | Open file manager (nautilus) |
| `SUPER`+`W` | Open browser (Brave) |
| `SUPER`+`C` | Open Chromium |
| `SUPER`+`Space` | App launcher (rofi, drun) |
| `SUPER`+`SHIFT`+`Space` | Alternate launcher (wofi, drun) |

## Screenshots & Recording

| Key | Action |
|-----|--------|
| `Print` | Full screenshot → `~/Pictures/Screenshots/Fullscreen/` + clipboard |
| `SUPER`+`SHIFT`+`S` | Selection screenshot → `~/Pictures/Screenshots/Freeform/` + clipboard |
| `SUPER`+`SHIFT`+`T` | OCR screenshot (eink-ocr) |
| `SUPER`+`R` | Toggle fullscreen recording (wf-recorder, with audio) |
| `SUPER`+`SHIFT`+`R` | Toggle region recording (slurp + wf-recorder) |
| `SUPER`+`S` | Stop any active recording |

## System

| Key | Action |
|-----|--------|
| `SUPER`+`L` | Lock screen (hyprlock) |
| `SUPER`+`P` | Power menu (rofi) |
| `SUPER`+`N` | Toggle notification panel (swaync) |
| `SUPER`+`V` | Clipboard history — pick to copy (rofi + cliphist) |
| `SUPER`+`SHIFT`+`V` | Clipboard history — pick to delete |
| `SUPER`+`ALT`+`V` | Wipe clipboard history |
| `SUPER`+`SHIFT`+`C` | Color picker (hyprpicker, copies hex) |
| `SUPER`+`SHIFT`+`W` | Wallpaper picker (static + live) |
| `SUPER`+`CTRL`+`Q` | Exit Hyprland |

## Multimedia Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up (5%) |
| `XF86AudioLowerVolume` | Volume down (5%) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `XF86AudioPlay` | Play/pause (playerctl) |
| `XF86AudioPause` | Pause (playerctl) |
| `XF86AudioNext` | Next track (playerctl) |
| `XF86AudioPrev` | Previous track (playerctl) |

## Waybar Click Actions

| Module | Left Click | Right Click | Scroll |
|--------|-----------|-------------|--------|
| **Workspaces** | Focus workspace | — | Cycle workspaces |
| **Media** | Play/Pause | Stop | Next/Previous |
| **Network** | Open impala (WiFi TUI) | — | — |
| **Bluetooth** | Open bluetui | — | — |
| **Audio** | Open pulsemixer | — | Volume up/down |
| **Brightness** | — | — | Brightness up/down |
| **CPU** | Open btop | — | — |
| **Memory** | Open btop | — | — |
| **Power Profile** | Cycle profile | — | — |
| **Notification** | Toggle panel | Toggle DnD | — |
| **Power** | Power menu | — | — |
