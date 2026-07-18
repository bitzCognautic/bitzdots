# Scripts

All custom scripts are in `~/.config/scripts/`.

## Recording Scripts

### `record-fullscreen.sh`

Starts fullscreen screen recording with audio from the default sink monitor.

- **Trigger**: `SUPER+R`
- **Output**: `~/Videos/Recordings/Fullscreen/recording_YYYYMMDD_HHMMSS.mp4`
- **Audio**: Internal desktop audio only (no microphone)
- **Guard**: Atomic `mkdir` debounce + `pgrep -x wf-recorder` cross-type guard
- **Details**: Sets monitor volume to 100%, saves with notification

### `record-region.sh`

Starts region screen recording with audio.

- **Trigger**: `SUPER+SHIFT+R`
- **Selection**: `slurp` — click and drag to select area
- **Output**: `~/Videos/Recordings/Region/recording_YYYYMMDD_HHMMSS.mp4`
- **Audio**: Internal desktop audio only
- **Guard**: Same as fullscreen script

### `recording-indicator.sh`

Waybar custom module that blinks `` when recording is active.

- **Trigger**: Polled by waybar every 10s
- **Mechanism**: Checks `pgrep -x wf-recorder`
- **Output**: Waybar JSON with text and CSS class

**Note on Hydra/SuperHypr**: If you use the Hydra tool from SuperHypr, its recording script also uses `wf-recorder` and has the same atomic `mkdir` debounce mechanism.

## Utility Scripts

### `media.sh`

Media player controls for `playerctl`.

- Shows current track in waybar
- Displays album art in SwayNC notifications
- **Lightweight**: Kills any lingering `playerctl metadata --follow` on startup

### `power-profile.sh`

Displays current power profile in waybar.

- Uses `busctl` directly on UPower D-Bus (no `powerprofilesctl` which can hang)
- Instant results with no CPU spikes

### `power-profile-switch.sh`

Cycles through power profiles: performance → balanced → power-saver.

- On-click action for waybar
- Sends notification on profile change

### `screenshot.sh`

Handles fullscreen and region screenshots.

- **Full**: `grim` → `~/Pictures/Screenshots/Fullscreen/` + `wl-copy` clipboard
- **Region**: `grim -g "$(slurp)"` → `~/Pictures/Screenshots/Freeform/` + clipboard
- Sends notification with file path

## Debounce Mechanism

All Hyprland-triggered scripts use atomic `mkdir` for debounce:

```bash
DEBOUNCE_DIR="/tmp/script-name.debounce"
if ! mkdir "$DEBOUNCE_DIR" 2>/dev/null; then exit 0; fi
trap "rmdir '$DEBOUNCE_DIR'" EXIT
```

This prevents double-firing from Hyprland which can trigger keybinds twice per press.
