#!/usr/bin/bash

# Add hyprlock configuration to match system theme
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

# Main hyprlock config generation (simplified — expand as needed)
cat <<EOF > "$HYPRLOCK_CONF"
background-image = ~/.cache/current_wallpaper.png
background-color = #252827

# Main lock screen UI text
font-family = "JetBrainsMono Nerd Font"
font-size = 30

input-field {
    font-size = 20
    round-corners = false
    require-lockscreen = true
}

button {
    font-size = 20
    round-corners = false
    hyphens = false
}

label {
    font-size = 20
}

module {
    icon {
        theme = Dark
    }
}
EOF

chmod 644 "$HYPRLOCK_CONF"
