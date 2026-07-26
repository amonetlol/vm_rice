local home = os.getenv("HOME") or "~"
local scripts = home .. "/.config/hypr4/scripts"
local waybar_cfg = home .. "/.config/hypr4/waybar/config.jsonc"
local waybar_css = home .. "/.config/hypr4/waybar/style.css"

local exec_once = {
  scripts .. "/WallpaperDaemon.sh",
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP DESKTOP_SESSION XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE DISPLAY SSH_AUTH_SOCK TZ",
  "gnome-keyring-daemon --start --components=secrets,ssh,pkcs11",
  "waybar -c " .. waybar_cfg .. " -s " .. waybar_css,
}

hl.on("hyprland.start", function()
  for _, command in ipairs(exec_once) do
    hl.exec_cmd(command)
  end
end)
