-- hypr4 binds — ALT for apps; workspaces on SUPER (Jules + user request)

local home = os.getenv("HOME") or "~"
local mainMod = "ALT"
local scripts = home .. "/.config/hypr4/scripts"
local rofi_cfg = home .. "/.config/hypr4/rofi/config.rasi"

local function bind(combo, dispatcher, description, opts)
  opts = opts or {}
  if description then opts.description = description end
  hl.bind(combo, dispatcher, opts)
end

local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

-- Apps (requested)
bind(mainMod .. " + D", exec("pkill rofi 2>/dev/null; rofi -show drun -no-lazy-grab -config " .. rofi_cfg), "rofi drun")
bind(mainMod .. " + Return", exec("foot"), "terminal")
bind(mainMod .. " + W", exec("firefox"), "firefox")
bind(mainMod .. " + X", exec(scripts .. "/Wlogout.sh"), "wlogout")
bind(mainMod .. " + E", exec("thunar"), "file manager")
bind(mainMod .. " + Q", hl.dsp.window.close(), "close window")
bind("SUPER + Q", hl.dsp.window.close(), "close window")
bind(mainMod .. " + F", hl.dsp.window.fullscreen(), "fullscreen")
bind(mainMod .. " + F12", exec(scripts .. "/RefreshWaybar.sh"), "refresh waybar")

-- Jules extras (SUPER modifier)
bind("SUPER + R", exec(scripts .. "/reload.sh"), "reload accessories")
bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }), "toggle float")
bind("SUPER + P", hl.dsp.window.pseudo(), "pseudo")
bind("SUPER + J", hl.dsp.layout("togglesplit"), "toggle split")

-- Focus / move (SUPER + arrows)
bind("SUPER + left", hl.dsp.focus({ direction = "left" }), "focus left")
bind("SUPER + right", hl.dsp.focus({ direction = "right" }), "focus right")
bind("SUPER + up", hl.dsp.focus({ direction = "up" }), "focus up")
bind("SUPER + down", hl.dsp.focus({ direction = "down" }), "focus down")

bind("SUPER + mouse:272", hl.dsp.window.drag(), "drag", { mouse = true })
bind("SUPER + mouse:273", hl.dsp.window.resize(), "resize", { mouse = true })

-- Workspaces on SUPER
for i = 1, 10 do
  local key = i == 10 and 0 or i
  bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }), "workspace " .. i)
  bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "move to workspace " .. i)
end
bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "next workspace")
bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "previous workspace")

-- Multimedia keys
bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "volume up", { locked = true, repeating = true })
bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), "volume down", { locked = true, repeating = true })
bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), "mute", { locked = true, repeating = true })
bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), "mic mute", { locked = true, repeating = true })
bind("XF86MonBrightnessUp", exec("brightnessctl -e4 -n2 set 5%+"), "brightness up", { locked = true, repeating = true })
bind("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"), "brightness down", { locked = true, repeating = true })
