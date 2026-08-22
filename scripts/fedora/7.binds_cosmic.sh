#!/usr/bin/env bash
# Cosmic DE keybinds for vm_rice (replaces GNOME gsettings/dconf approach)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_fedora

COSMIC_SHORTCUTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
COSMIC_SHORTCUTS_FILE="${COSMIC_SHORTCUTS_DIR}/custom"

BRAVE_CMD="brave-browser"
if ! command -v "$BRAVE_CMD" &>/dev/null; then
  if command -v brave &>/dev/null; then
    BRAVE_CMD="brave"
  else
    warn "brave-browser not found — keybind will be set anyway"
  fi
fi

TERMINAL_CMD=""
for candidate in cosmic-term blackbox-terminal blackbox alacritty kitty; do
  if command -v "$candidate" &>/dev/null; then
    TERMINAL_CMD="$candidate"
    break
  fi
done
# Flatpak BlackBox fallback
if [[ -z "$TERMINAL_CMD" ]] && command -v flatpak &>/dev/null; then
  if flatpak info com.raggesilver.BlackBox &>/dev/null; then
    TERMINAL_CMD="flatpak run com.raggesilver.BlackBox"
  fi
fi
[[ -n "$TERMINAL_CMD" ]] || { TERMINAL_CMD="cosmic-term"; warn "No terminal found — defaulting to cosmic-term"; }

FILE_MGR_CMD="cosmic-files"
if ! command -v "$FILE_MGR_CMD" &>/dev/null; then
  if command -v nautilus &>/dev/null; then
    FILE_MGR_CMD="nautilus"
  elif command -v thunar &>/dev/null; then
    FILE_MGR_CMD="thunar"
  else
    warn "No file manager found — keybind will be set anyway"
    FILE_MGR_CMD="cosmic-files"
  fi
fi

ULAUNCHER_CMD="ulauncher"
command -v "$ULAUNCHER_CMD" &>/dev/null || warn "ulauncher not found — keybind will be set anyway"

write_cosmic_shortcuts() {
  mkdir -p "$COSMIC_SHORTCUTS_DIR"

  # Cosmic uses RON format; gsettings/dconf are NOT used (GNOME-specific).
  cat > "$COSMIC_SHORTCUTS_FILE" <<EOF
{
    (
        modifiers: [Alt],
        key: "Return",
        description: Some("Open terminal (Alt+Return)"),
    ): Spawn("${TERMINAL_CMD}"),
    (
        modifiers: [Super],
        key: "Return",
        description: Some("Open terminal (Super+Return)"),
    ): Spawn("${TERMINAL_CMD}"),
    (
        modifiers: [Alt],
        key: "w",
        description: Some("Open Brave (Alt+W)"),
    ): Spawn("${BRAVE_CMD}"),
    (
        modifiers: [Super],
        key: "w",
        description: Some("Open Brave (Super+W)"),
    ): Spawn("${BRAVE_CMD}"),
    (
        modifiers: [Alt],
        key: "e",
        description: Some("Open file manager (Alt+E)"),
    ): Spawn("${FILE_MGR_CMD}"),
    (
        modifiers: [Super],
        key: "e",
        description: Some("Open file manager (Super+E)"),
    ): Spawn("${FILE_MGR_CMD}"),
    (
        modifiers: [Alt],
        key: "d",
        description: Some("Open Ulauncher (Alt+D)"),
    ): Spawn("${ULAUNCHER_CMD}"),
    (
        modifiers: [Super],
        key: "d",
        description: Some("Open Ulauncher (Super+D)"),
    ): Spawn("${ULAUNCHER_CMD}"),
    (
        modifiers: [Alt],
        key: "q",
        description: Some("Close window (Alt+Q)"),
    ): Close,
}
EOF

  ok "Wrote Cosmic shortcuts to ${COSMIC_SHORTCUTS_FILE}"
}

reload_cosmic_settings() {
  if command -v cosmic-settings-daemon &>/dev/null; then
    killall cosmic-settings-daemon 2>/dev/null || true
    cosmic-settings-daemon &>/dev/null &
    ok "Restarted cosmic-settings-daemon"
  else
    warn "cosmic-settings-daemon not running — log out/in or restart Cosmic to apply keybinds"
  fi
}

log "Configuring Cosmic DE keybinds..."
write_cosmic_shortcuts
reload_cosmic_settings

ok "Cosmic keybinds configured"
printf '  Close window : Alt+Q (Super+Q is Cosmic default)\n'
printf '  Terminal     : Alt+Return, Super+Return (%s)\n' "$TERMINAL_CMD"
printf '  Browser      : Alt+W, Super+W (%s)\n' "$BRAVE_CMD"
printf '  File manager : Alt+E, Super+E (%s)\n' "$FILE_MGR_CMD"
printf '  Ulauncher    : Alt+D, Super+D\n'
