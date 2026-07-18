# Customization

## Changing Keybindings

All keybindings are in `hypr/keybinds.lua`. The file uses Hyprland's Lua API:

```lua
-- Example: bind SUPER+O to open file manager
bind = "SUPER, O, exec, thunar"
```

After editing, reload with `SUPER+SHIFT+E`.

## Adding Waybar Modules

1. Add module to `waybar/config.jsonc`:

```jsonc
"custom/my-module": {
    "exec": "~/path/to/script.sh",
    "interval": 30,
    "return-type": "json"
}
```

2. Style it in `waybar/style.css`:

```css
#custom-my-module {
    color: @color4;
    padding: 0 10px;
}
```

3. Reload with `SUPER+SHIFT+C`

## Custom Wallust Templates

Templates live in `wallust/templates/`. They use Jinja2 syntax:

```jinja
background: {{color0}}
foreground: {{color7}}
accent: {{color4}}
```

Add a new template file and it will be processed on next `wallust run`.

## Rofi Themes

Rofi configs are in `rofi/*.rasi`. Each launcher has its own theme file. Edit colors directly or let wallust manage them.

## SwayNC Notifications

Edit `swaync/config.json` for behavior and `swaync/style.css` for appearance. The style is also wallust-managed.

## Adding Custom Scripts

1. Create your script in `scripts/`
2. Make it executable: `chmod +x scripts/my-script.sh`
3. Add a keybind in `hypr/keybinds.lua` or a waybar module in `waybar/config.jsonc`

### Script Best Practices

- Use atomic `mkdir` for debounce if Hyprland-triggered
- Use `pgrep` for process guarding
- Send notifications with `notify-send`
- Keep polling intervals ≥ 5 seconds for performance

## Disabling Components

### Disable Waybar

Remove or comment out `bar` in `hypr/hyprland.conf`, or toggle with `SUPER+B`.

### Disable SwayNC

Remove swaync from autostart in `hypr/hyprland.conf`.

### Disable Animation

In `hypr/appearance.lua`:

```lua
animations = {
    enabled = false
}
```

## Color Scheme Options

Wallust generates 16 colors. You can customize the color mapping in templates:

| Variable | Typical Use |
|----------|-------------|
| `color0` | Background |
| `color1` | Red, errors |
| `color2` | Green, success |
| `color3` | Yellow, warnings |
| `color4` | Blue, accent |
| `color5` | Purple |
| `color6` | Cyan |
| `color7` | Foreground |
| `color8-15` | Light/bright variants |
