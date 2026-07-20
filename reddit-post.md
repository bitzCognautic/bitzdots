**bitzdots — lean Hyprland dotfiles that auto-theme everything from one wallpaper, optimized for low-end machines** [OC]

[github.com/bitzCognautic/bitzdots](https://github.com/bitzCognautic/bitzdots)

Been working on this for a while and figured I'd share. The core idea: pick any wallpaper, and **every** themed component updates automatically — waybar, rofi, swaync, terminal, even browser CSS. No manual color picking, no mismatched themes.

**Stack**: Hyprland + wallust (26 Jinja2 templates) + waybar + rofi + swaync

**Key features:**
- Full-stack auto-theming — 20+ components update from one wallpaper
- Event-driven cache daemon — instant wallpaper switching (inotify + pre-generation)
- Rofi-powered everything — app launcher, clipboard, power menu, wallpaper picker, WiFi, Bluetooth
- Screenshot + recording with clipboard integration
- 26 wallust templates — consistent colors everywhere
- Multi-distro installer (Arch, Fedora, Debian, NixOS)
- Safe theme switching — backup/restore on every wallust run

**Performance focus:**
- ~250-300MB RAM idle (full stack)
- ~3.5% CPU idle (waybar)
- All polling intervals ≤ 30s
- No playerctl metadata leaks
- busctl instead of powerprofilesctl (avoids 100% CPU hangs)

**Quick start:**
```bash
git clone https://github.com/bitzCognautic/bitzdots.git ~/.config/bitzdots
cd ~/.config/bitzdots && ./install.sh --with-deps
```

Wiki with full docs: [github.com/bitzCognautic/bitzdots/wiki](https://github.com/bitzCognautic/bitzdots/wiki)
