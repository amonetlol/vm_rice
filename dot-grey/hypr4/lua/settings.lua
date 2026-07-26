-- Core settings + br ABNT2 + VMware-friendly cursor

hl.config({
  input = {
    kb_layout = "br",
    kb_variant = "abnt2",
    kb_options = "caps:escape",
    repeat_rate = 40,
    repeat_delay = 400,
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      disable_while_typing = true,
    },
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = false,
    vrr = 0,
    focus_on_activate = true,
    force_default_wallpaper = 0,
  },
  cursor = {
    no_hardware_cursors = 2,
    enable_hyprcursor = true,
    no_warps = true,
    sync_gsettings_theme = true,
  },
  xwayland = { enabled = true, force_zero_scaling = true },
  dwindle = { preserve_split = true, smart_split = false, force_split = 2 },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
