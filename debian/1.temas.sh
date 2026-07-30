#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

detect_real_user
export HOME="$REAL_HOME"
THEMES_DIR="$HOME/.themes"
CAT_REPO="https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme.git"
CAT_DIR="$DOT_CACHE/Catppuccin-GTK-Theme"

log "Installing Catppuccin GTK themes to $THEMES_DIR"

if [[ "$(id -u)" -eq 0 ]]; then
  apt-get install -y sassc git
else
  sudo apt-get install -y sassc git
fi

ensure_dot_cache
mkdir -p "$THEMES_DIR"
clone_or_update "$CAT_REPO" "$CAT_DIR"

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$CAT_DIR" "$THEMES_DIR"
fi

log "Building themes (blue, teal, sapphire, sky — mocha, macchiato, frappe)..."
run_as_user "cd '$CAT_DIR/themes' && CI=1 printf '\\n' | ./install.sh \
  -d '$THEMES_DIR' \
  -a blue teal sapphire sky \
  -m dark \
  -l mocha macchiato frappe \
  --tweaks border macos"

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$THEMES_DIR"
fi

ok "Catppuccin GTK themes installed in $THEMES_DIR"
ls "$THEMES_DIR" 2>/dev/null | head -10 || true