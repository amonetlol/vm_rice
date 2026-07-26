-- Window and layer rules (Jules adapted — rofi not wofi, no swaync)

hl.window_rule({ match = { class = "^([Ff]irefox|org.mozilla.firefox)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^(foot)$" }, tag = "+terminal" })
hl.window_rule({ match = { class = "^(Thunar)$" }, tag = "+files" })
hl.window_rule({ match = { class = "^(wlogout)$" }, opacity = 0.95 })

hl.window_rule({
  match = { pin = true },
  border_color = "rgb(ffffff) rgb(5adecd)",
  border_size = 2,
})

hl.window_rule({
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

hl.layer_rule({
  match = { namespace = "waybar" },
  blur = true,
  ignore_alpha = 0.5,
  no_anim = true,
})

hl.layer_rule({
  match = { namespace = "rofi" },
  blur = true,
  ignore_alpha = 0.5,
})

hl.layer_rule({
  match = { namespace = "gtk-layer-shell" },
  blur = true,
  ignore_alpha = 0.1,
  animation = "slide top",
  xray = true,
})
