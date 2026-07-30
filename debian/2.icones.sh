#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

detect_real_user
export HOME="$REAL_HOME"
ICONS_DIR="$HOME/.icons"
MC_REPO="https://github.com/vinceliuice/McMojave-circle.git"
MC_DIR="$DOT_CACHE/McMojave-circle"

log "Installing McMojave-circle icons to $ICONS_DIR"

if ! command -v git &>/dev/null; then
  if [[ "$(id -u)" -eq 0 ]]; then
    apt-get install -y git
  else
    sudo apt-get install -y git
  fi
fi

ensure_dot_cache
mkdir -p "$ICONS_DIR"
clone_or_update "$MC_REPO" "$MC_DIR"

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$MC_DIR" "$ICONS_DIR"
fi

log "Running McMojave-circle install..."
run_as_user "cd '$MC_DIR' && ./install.sh -d '$ICONS_DIR' -a" 2>/dev/null || \
  run_as_user "cd '$MC_DIR' && ./install.sh -d '$ICONS_DIR'"

log "Cleaning up ubuntu/manjaro icon folders (Qogir leftovers)..."
run_as_user "source '$SCRIPT_DIR/common.sh' && cleanup_icon_dirs"

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$ICONS_DIR"
fi

ok "McMojave-circle icons installed in $ICONS_DIR"
ls "$ICONS_DIR" 2>/dev/null | head -10 || true