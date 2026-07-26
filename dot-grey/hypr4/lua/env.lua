-- Environment: VMware + São Paulo + Hyprland session (hypr4)

local home = os.getenv("HOME") or "/home/rice"
local rt = os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000"

hl.env("TZ", "America/Sao_Paulo")
hl.env("EDITOR", "nvim")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("DESKTOP_SESSION", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("SSH_AUTH_SOCK", rt .. "/keyring/ssh")

hl.env("FOOTINI", home .. "/.config/hypr4/foot/foot.ini")

-- VMware / software rendering helpers
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("LIBGL_ALWAYS_SOFTWARE", "0")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card0")

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")

hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")
