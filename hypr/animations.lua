hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })
hl.curve("smooth",   { type = "bezier", points = { { 0.25, 0.1 },  { 0.25, 1 }  } })
hl.curve("snappy",   { type = "bezier", points = { { 0.2, 0.8 },   { 0.2, 1 }   } })
hl.curve("linear",   { type = "bezier", points = { { 0, 0 },       { 1, 1 }     } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "snappy",   style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "smooth",  style = "slide" })
hl.animation({ leaf = "fade",        enabled = false })
hl.animation({ leaf = "fadeSwitch",  enabled = false })
hl.animation({ leaf = "fadeShadow",  enabled = false })
hl.animation({ leaf = "fadeDim",     enabled = false })
hl.animation({ leaf = "border",     enabled = true, speed = 7, bezier = "overshot" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "linear", style = "slidevert" })
