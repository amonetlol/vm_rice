#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

detect_real_user
export HOME="$REAL_HOME"
ICONS_DIR="$HOME/.icons"
LOCAL_ICONS="$HOME/.local/share/icons"
QOGIR_REPO="https://github.com/vinceliuice/Qogir-icon-theme.git"
QOGIR_DIR="$DOT_CACHE/Qogir-icon-theme"

log "Installing Qogir cursor theme"

if ! command -v git &>/dev/null; then
  if [[ "$(id -u)" -eq 0 ]]; then
    apt-get install -y git
  else
    sudo apt-get install -y git
  fi
fi

ensure_dot_cache
mkdir -p "$ICONS_DIR" "$LOCAL_ICONS"
clone_or_update "$QOGIR_REPO" "$QOGIR_DIR"

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$QOGIR_DIR" "$ICONS_DIR" "$LOCAL_ICONS"
fi

log "Installing cursor variants..."
run_as_user "cd '$QOGIR_DIR' && ./install.sh -c" 2>/dev/null || \
  run_as_user "cd '$QOGIR_DIR' && ./install.sh"

log "Cleaning up ubuntu/manjaro icon folders..."
run_as_user "source '$SCRIPT_DIR/common.sh' && cleanup_icon_dirs"

for cursor_theme in Qogir-cursors Qogir Qogir-dark-cursors; do
  if [[ -d "$ICONS_DIR/$cursor_theme" || -d "$LOCAL_ICONS/$cursor_theme" || -d "/usr/share/icons/$cursor_theme" ]]; then
    run_gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
    ok "Cursor theme set to $cursor_theme"
    break
  fi
done

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$ICONS_DIR" "$LOCAL_ICONS"
fi

ok "Qogir cursor installed"