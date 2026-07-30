#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

detect_real_user
export HOME="$REAL_HOME"
BASE_REPO="https://github.com/amonetlol/base.git"
SCRIPTS_REPO="https://github.com/amonetlol/scripts.git"
WALL_REPO="https://github.com/amonetlol/wall2.git"
BASE_DIR="$DOT_CACHE/base"
SCRIPTS_DIR="$DOT_CACHE/scripts"
WALL_DIR="$HOME/Imagens/wallpapers"

log "Installing amonetlol configs as $REAL_USER"

if ! command -v git &>/dev/null; then
  if [[ "$(id -u)" -eq 0 ]]; then
    apt-get install -y git
  else
    sudo apt-get install -y git
  fi
fi

ensure_dot_cache
clone_or_update "$BASE_REPO" "$BASE_DIR"
clone_or_update "$SCRIPTS_REPO" "$SCRIPTS_DIR"

mkdir -p "$HOME/Imagens"
clone_or_update "$WALL_REPO" "$WALL_DIR"

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$DOT_CACHE" "$HOME/Imagens" "$HOME/.config" "$HOME/.local" 2>/dev/null || true
fi

export DOT_CACHE="$DOT_CACHE"
export DOT_REPO_URL="https://github.com/amonetlol/dot.git"

run_module() {
  local script="$1"
  log "Running $script..."
  if run_as_user "cd '$BASE_DIR' && bash modules/$script"; then
    ok "$script"
  else
    warn "$script failed partially — continuing"
  fi
}

run_module install-bash.sh
run_module install-bin.sh
run_module install-fonts.sh
run_module install-starship.sh
run_module install-fastfetch.sh

log "Running setup-nvim.sh..."
run_as_user "bash '$BASE_DIR/modules/setup-nvim.sh'" || warn "setup-nvim.sh failed partially"

log "Running install-ulauncher-catppuccin.sh..."
if run_as_user "bash '$SCRIPTS_DIR/install-ulauncher-catppuccin.sh'"; then
  ok "Ulauncher Catppuccin theme installed"
else
  warn "Falling back to Catppuccin ulauncher installer"
  run_as_user "python3 <(curl -fsSL https://raw.githubusercontent.com/catppuccin/ulauncher/main/install.py) -f mocha frappe -a blue" || true
fi

if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "$REAL_USER:$REAL_USER" "$HOME" 2>/dev/null || true
fi

ok "Dotfile configs installed"