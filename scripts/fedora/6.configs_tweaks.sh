#!/usr/bin/env bash
# Configs, tweaks, and debloat (Cosmic DE — no GNOME extensions)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/snapper.sh
source "${SCRIPT_DIR}/lib/snapper.sh"
# shellcheck source=lib/fonts.sh
source "${SCRIPT_DIR}/lib/fonts.sh"

require_fedora

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
    if run_as_root dnf install -y ulauncher 2>/dev/null; then
      ok "ulauncher installed via dnf"
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
  # Arch-specific packages from original; Fedora equivalents if present.
  local pkg
  for pkg in sane; do
    if rpm -q "$pkg" &>/dev/null; then
      log "Removing ${pkg}..."
      run_as_root dnf remove -y "$pkg" || warn "Failed to remove ${pkg}"
    else
      log "${pkg} not installed — skipping"
    fi
  done
}

main() {
  log "=== amonetlol scripts ==="
  for url in "${AMONET_SCRIPTS[@]}"; do
    run_remote_script "$url"
  done
  run_amonet_modules

  log "=== Custom nerd fonts ==="
  install_custom_nerd_fonts || warn "Custom nerd font install failed"

  log "=== GNOME extensions ==="
  log "Skipping GNOME extensions (Cosmic DE — not applicable)"

  log "=== Debloat ==="
  debloat_packages

  log "=== Snapper snapshot limits ==="
  configure_snapper_limits 6

  ok "Configs, tweaks, and debloat complete"
}

main
