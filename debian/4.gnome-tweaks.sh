#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

detect_real_user
export HOME="$REAL_HOME"
CLOSE_BIN="$HOME/.local/bin/close-window"

log "Applying GNOME tweaks and keybinds"

mkdir -p "$HOME/.local/bin"

cat > "$CLOSE_BIN" << 'CLOSEEOF'
#!/usr/bin/env bash
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
  --method org.gnome.Shell.Eval \
  'const w = global.display.get_focus_window(); if (w) w.delete(global.get_current_time());' >/dev/null 2>&1
CLOSEEOF
chmod +x "$CLOSE_BIN"

if [[ "$(id -u)" -eq 0 ]]; then
  chown "$REAL_USER:$REAL_USER" "$CLOSE_BIN"
fi

run_gsettings set org.gnome.shell always-show-log-out true
run_dconf write /org/gnome/shell/always-show-log-out true

CUSTOM_SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

run_gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/']"

bind_custom() {
  local idx="$1" name="$2" cmd="$3" binding="$4"
  local path="${CUSTOM_PATH}/custom${idx}/"
  run_gsettings set "${CUSTOM_SCHEMA}${path}" name "$name"
  run_gsettings set "${CUSTOM_SCHEMA}${path}" command "$cmd"
  run_gsettings set "${CUSTOM_SCHEMA}${path}" binding "$binding"
  ok "Keybind custom${idx}: $binding -> $name"
}

bind_custom 0 'close-window-alt-q' "$CLOSE_BIN" '<Alt>q'
bind_custom 1 'close-window-super-q' "$CLOSE_BIN" '<Super>q'
bind_custom 2 'terminal-alt-return' 'blackbox-terminal' '<Alt>Return'
bind_custom 3 'terminal-super-return' 'blackbox-terminal' '<Super>Return'
bind_custom 4 'brave-alt-w' 'brave-browser' '<Alt>w'
bind_custom 5 'brave-super-w' 'brave-browser' '<Super>w'
bind_custom 6 'ulauncher-alt-d' 'ulauncher-toggle' '<Alt>d'
bind_custom 7 'ulauncher-super-d' 'ulauncher-toggle' '<Super>d'
bind_custom 8 'nautilus-alt-e' 'nautilus' '<Alt>e'
bind_custom 9 'nautilus-super-e' 'nautilus' '<Super>e'

run_gsettings set org.gnome.mutter overlay-key ''

ok "GNOME tweaks and keybinds applied"