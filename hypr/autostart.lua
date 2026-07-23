hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl setcursor catppuccin-mocha-dark-cursors 24")
    hl.exec_cmd("waybar &")
    hl.exec_cmd("swaync")
    hl.exec_cmd("polkit-kde-authentication-agent-1")
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- Start wallpaper daemon and restore last wallpaper
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("bash -c 'sleep 0.5 && test -f $HOME/.cache/current_wallpaper.png && awww img $HOME/.cache/current_wallpaper.png'")

    -- Wallust palette cache daemon runs as a systemd user service
    -- (wallust-cache-daemon.service) — no need to start it here
end)
