# FAQ

## General

### What is bitzdots?

bitzdots is a collection of Hyprland dotfiles focused on low-end performance, automatic wallust theming, and a clean workflow. It includes configurations for waybar, rofi, swaync, fish, and 26 wallust templates.

### Is this for me?

If you want a performant, auto-themed Hyprland setup that runs well on older hardware, yes. The setup is opinionated but highly customizable.

### How is this different from other dotfiles?

- **Performance-first** — Every component is tuned for low CPU/RAM usage
- **Auto-coloring pipeline** — 26 Jinja2 templates update automatically with any wallpaper
- **Comprehensive** — Recording, screenshots, media control, power management, notification center out of the box

## Installation

### Do I need to start from a fresh install?

No, but you should have Hyprland installed and working. The install script will handle dependencies.

### Can I use this with NixOS?

The configs are Arch Linux-focused but the Hyprland, waybar, and rofi components should work on any distro with the right packages.

### Will this overwrite my existing configs?

The install script is designed to drop files into `~/.config/`. Back up your existing configs first.

## Usage

### How do I change my wallpaper?

```bash
wallust run /path/to/wallpaper.jpg
```

This updates all 26 themed configs automatically.

### How do I add a custom keybind?

Edit `hypr/keybinds.lua` and reload with `SUPER+SHIFT+E`.

### My recording has no audio?

Ensure `--audio="$AUDIO"` is present in the recording script (it should be). The audio source is the default sink monitor (desktop audio, not microphone).

### Why does Hyprland fire keybinds twice?

This is a known Hyprland issue. All recording scripts use an atomic `mkdir` debounce to prevent double execution.

## Troubleshooting

### Waybar shows "Not Available"

Check that the module's dependencies are installed. For example, `custom/power-profiles` needs `power-profiles-daemon` running.

### SwayNC notifications not showing

Ensure `swaync` is running. Toggle with `SUPER+B` if it's hidden behind waybar.

### Wallust colors not applying

Make sure wallust is installed and templates are in `wallust/templates/`. Run `wallust run /path/to/wallpaper.jpg` manually.

### Fish greeter still shows

Edit `fish/config.fish` and ensure `set -U fish_greeting` is present, then restart fish.

## Customization

### Can I use a different terminal?

Change the terminal command in `hypr/keybinds.lua`.

### Can I remove the recording indicator?

Comment out or remove the `custom/recording` module from `waybar/config.jsonc`.

### How do I add my own waybar modules?

1. Add module config to `waybar/config.jsonc`
2. Add CSS in `waybar/style.css`
3. Optionally add a custom script in `scripts/`
4. Reload waybar with `SUPER+SHIFT+C`
