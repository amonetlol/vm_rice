#!/usr/bin/env bash
# GNOME keybinds for vm_rice
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_arch

BRAVE_CMD="brave"
if ! command -v brave &>/dev/null; then
  if command -v brave-browser &>/dev/null; then
  BRAVE_CMD="brave-browser"
  elif command -v brave-origin &>/dev/null; then
  BRAVE_CMD="brave-origin"
  fi
fi

TERMINAL_CMD="blackbox-terminal"
if ! command -v "$TERMINAL_CMD" &>/dev/null; then
  if command -v blackbox &>/dev/null; then
    TERMINAL_CMD="blackbox"
  elif command -v flatpak &>/dev/null && flatpak info com.raggesilver.BlackBox &>/dev/null; then
    TERMINAL_CMD="flatpak run com.raggesilver.BlackBox"
  else
    TERMINAL_CMD="gnome-terminal"
  fi
fi

ULAUNCHER_CMD="ulauncher"
command -v "$ULAUNCHER_CMD" &>/dev/null || warn "ulauncher not found — keybind will be set anyway"

NAUTILUS_CMD="nautilus"
if ! command -v nautilus &>/dev/null; then
  if command -v gio &>/dev/null; then
    NAUTILUS_CMD="gio launch org.gnome.Nautilus"
  else
    warn "nautilus not found — keybind will be set anyway"
  fi
fi

CUSTOM_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

set_custom_binding() {
  local id="$1"
  local name="$2"
  local command="$3"
  local binding="$4"
  local path="${CUSTOM_BASE}/${id}/"

  gsettings set "${CUSTOM_SCHEMA}.custom-keybinding:${path}" name "$name"
  gsettings set "${CUSTOM_SCHEMA}.custom-keybinding:${path}" command "$command"
  gsettings set "${CUSTOM_SCHEMA}.custom-keybinding:${path}" binding "$binding"
}

register_custom_paths() {
  local paths=("$@")
  local joined=""
  local p
  for p in "${paths[@]}"; do
  joined+="'${p}',"
  done
  joined="[${joined%,}]"
  gsettings set "${CUSTOM_SCHEMA}" custom-keybindings "$joined"
}

log "Setting window close keybinds (Alt+Q, Super+Q)..."
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>q', '<Super>q']"

log "Configuring custom application keybinds..."
register_custom_paths \
  "${CUSTOM_BASE}/blackbox-alt/" \
  "${CUSTOM_BASE}/blackbox-super/" \
  "${CUSTOM_BASE}/brave-alt/" \
  "${CUSTOM_BASE}/brave-super/" \
  "${CUSTOM_BASE}/nautilus-alt/" \
  "${CUSTOM_BASE}/nautilus-super/" \
  "${CUSTOM_BASE}/ulauncher-alt/" \
  "${CUSTOM_BASE}/ulauncher-super/"

set_custom_binding "blackbox-alt" "Open Blackbox (Alt+Return)" "$TERMINAL_CMD" "<Alt>Return"
set_custom_binding "blackbox-super" "Open Blackbox (Super+Return)" "$TERMINAL_CMD" "<Super>Return"
set_custom_binding "brave-alt" "Open Brave (Alt+W)" "$BRAVE_CMD" "<Alt>w"
set_custom_binding "brave-super" "Open Brave (Super+W)" "$BRAVE_CMD" "<Super>w"
set_custom_binding "nautilus-alt" "Open Nautilus (Alt+E)" "$NAUTILUS_CMD" "<Alt>e"
set_custom_binding "nautilus-super" "Open Nautilus (Super+E)" "$NAUTILUS_CMD" "<Super>e"
set_custom_binding "ulauncher-alt" "Open Ulauncher (Alt+D)" "$ULAUNCHER_CMD" "<Alt>d"
set_custom_binding "ulauncher-super" "Open Ulauncher (Super+D)" "$ULAUNCHER_CMD" "<Super>d"

# dconf mirrors for robustness
dconf write /org/gnome/desktop/wm/keybindings/close "['<Alt>q', '<Super>q']" 2>/dev/null || true

ok "GNOME keybinds configured"
printf '  Close window : Alt+Q, Super+Q\n'
printf '  Terminal     : Alt+Return, Super+Return (%s)\n' "$TERMINAL_CMD"
printf '  Browser      : Alt+W, Super+W (%s)\n' "$BRAVE_CMD"
printf '  File manager : Alt+E, Super+E (%s)\n' "$NAUTILUS_CMD"
printf '  Ulauncher    : Alt+D, Super+D\n'
