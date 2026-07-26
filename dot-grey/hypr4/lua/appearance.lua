-- Jules3182 look and feel (teal accent #5adecd)

hl.config({
  general = {
    gaps_in = 10,
    gaps_out = { top = 5, right = 20, bottom = 0, left = 20 },
    border_size = 1,
    col = {
      active_border = { colors = { "rgba(ffffff55)", "rgba(5adecd99)" }, angle = 45 },
      inactive_border = "rgba(59595911)",
    },
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = false,
  },
  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
      vibrancy = 0.1696,
      xray = true,
    },
  },
  animations = {
    enabled = true,
  },
})
