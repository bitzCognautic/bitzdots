local ok, colors = pcall(require, "colors")
if not ok then
    colors = {
        background = "1a1218",
        foreground = "f2dde4",
        color0 = "1a1218",
        color1 = "f4a0b8",
        color4 = "c9a0b0",
        color6 = "c47aa8",
        color8 = "3d2838",
        color9 = "c94060",
    }
end

hl.config({
    general = {
        gaps_in            = 5,
        gaps_out           = 10,
        border_size        = 2,
        col = {
            active_border   = { colors = { "rgba(" .. colors.color1 .. "ee)", "rgba(" .. colors.color4 .. "ee)" }, angle = 45 },
            inactive_border = "rgba(" .. colors.color8 .. "ee)",
        },
        layout           = "dwindle",
        resize_on_border = false,
        allow_tearing    = false,
    },
    decoration = {
        rounding           = 0,
        active_opacity     = 1.0,
        inactive_opacity   = 0.9,
        fullscreen_opacity = 1.0,
        blur = {
            enabled            = true,
            size               = 8,
            passes             = 3,
            ignore_opacity     = false,
            new_optimizations  = true,
            contrast           = 0.9,
            brightness         = 1.0,
            noise              = 0.01,
            popups             = true,
            popups_ignorealpha = 0.2,
        },
        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = "0x99" .. colors.color0,
            offset       = "3 3",
            scale        = 0.95,
        },
    },
})
