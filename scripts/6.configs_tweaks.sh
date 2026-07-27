#!/usr/bin/env bash
# Configs, tweaks, and debloat (GNOME extensions installed manually)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/snapper.sh
source "${SCRIPT_DIR}/lib/snapper.sh"

require_arch

AMONET_SCRIPTS=(
  "https://raw.githubusercontent.com/amonetlol/scripts/main/install-ulauncher-catppuccin.sh"
)
AMONET_MODULES=(
  install-bash.sh
  install-bin.sh
  install-fonts.sh
  install-starship.sh
  install-wallpapers.sh
  setup-nvim.sh
  install-fastfetch.sh
)

run_remote_script() {
  local url="$1"
  local name
  name="$(basename "$url")"
  log "Running ${name}..."
  if [[ "$name" == *ulauncher* ]] && ! command -v ulauncher &>/dev/null; then
    log "Installing ulauncher..."
    if pacman -Si ulauncher &>/dev/null; then
      run_as_root pacman -S --needed --noconfirm ulauncher || warn "ulauncher pacman install failed"
    elif command -v yay &>/dev/null; then
      yay -S --needed --noconfirm --answerdiff None --answerclean None ulauncher \
        || warn "ulauncher AUR install failed"
    else
      warn "ulauncher not found — skipping ${name}"
      return 0
    fi
  fi
  bash <(curl -fsSL "$url") || warn "Remote script ${name} failed (continuing)"
  ok "Finished ${name}"
}

run_amonet_modules() {
  local dest
  dest="$(clone_or_update "https://github.com/amonetlol/base.git" amonet-base)"
  local mod
  for mod in "${AMONET_MODULES[@]}"; do
  local path="${dest}/modules/${mod}"
  [[ -f "$path" ]] || { warn "Module not found: ${mod}"; continue; }
  log "Running amonetlol module: ${mod}"
  bash "$path" || warn "Module ${mod} reported an error (continuing)"
  ok "Finished ${mod}"
  done
}

debloat_packages() {
  local pkg
  for pkg in sane shelly ptyxis; do
  if pacman -Qi "$pkg" &>/dev/null; then
    log "Removing ${pkg}..."
    run_as_root pacman -Rns --noconfirm "$pkg" || warn "Failed to remove ${pkg}"
  else
    log "${pkg} not installed — skipping"
  fi
  done
}

apply_logout_tweaks() {
  bash "${SCRIPT_DIR}/8.logout_fix.sh"
}

skip_gnome_extensions() {
  # App hider, blur my shell, dash to dock, impatience, tray icons reloaded,
  # user themes, vitals, paperwm — installed manually by the user.
  log "Skipping GNOME extensions (user installs manually)"
}

main() {
  log "=== amonetlol scripts ==="
  for url in "${AMONET_SCRIPTS[@]}"; do
  run_remote_script "$url"
  done
  run_amonet_modules

  log "=== GNOME extensions ==="
  skip_gnome_extensions

  log "=== Debloat ==="
  debloat_packages

  log "=== Snapper snapshot limits ==="
  configure_snapper_limits 6

  log "=== GNOME tweaks ==="
  apply_logout_tweaks

  ok "Configs, tweaks, and debloat complete"
}

main
