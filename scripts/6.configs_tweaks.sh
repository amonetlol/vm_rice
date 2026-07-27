#!/usr/bin/env bash
# Configs, tweaks, GNOME extensions, and debloat
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

install_gnome_extension() {
  local uuid="$1"
  local pkg="${2:-}"

  if command -v gnome-extensions &>/dev/null && gnome-extensions info "$uuid" &>/dev/null 2>&1; then
  log "Extension already present: ${uuid}"
  gnome-extensions enable "$uuid" 2>/dev/null || true
  return 0
  fi

  if [[ -n "$pkg" ]]; then
  if pacman -Si "$pkg" &>/dev/null 2>&1; then
    run_as_root pacman -S --needed --noconfirm "$pkg" || warn "pacman install failed: ${pkg}"
  elif command -v yay &>/dev/null && yay -Si "$pkg" &>/dev/null 2>&1; then
    yay -S --needed --noconfirm "$pkg" || warn "yay install failed: ${pkg}"
  else
    warn "Package not found in repos: ${pkg} (extension ${uuid})"
  fi
  fi

  if command -v gnome-extensions &>/dev/null; then
  gnome-extensions enable "$uuid" 2>/dev/null || warn "Could not enable ${uuid} — enable manually after login"
  fi
}

install_extensions() {
  log "Installing GNOME extensions..."
  # uuid | optional package name
  install_gnome_extension "app-hider@gcoulot" "gnome-shell-extension-app-hider"
  install_gnome_extension "blur-my-shell@emmanuelo95.gnome.shell.extensions" "gnome-shell-extension-blur-my-shell"
  install_gnome_extension "dash-to-dock@micxgx.gmail.com" "gnome-shell-extension-dash-to-dock"
  install_gnome_extension "impatience-gnome-refresh@nkmathe" "gnome-shell-extension-impatience"
  install_gnome_extension "TrayIconsReloaded@fthiess" "gnome-shell-extension-tray-icons-reloaded"
  install_gnome_extension "user-theme@gnome-shell-extensions.gcampax.github.com" "gnome-shell-extensions"
  install_gnome_extension "Vitals@CoreCoding.com" "gnome-shell-extension-vitals"
  install_gnome_extension "paperwm@paperwm.github.io" "gnome-shell-extension-paperwm"
  ok "GNOME extensions step completed (some may need manual enable in Extension Manager)"
}

main() {
  log "=== amonetlol scripts ==="
  for url in "${AMONET_SCRIPTS[@]}"; do
  run_remote_script "$url"
  done
  run_amonet_modules

  log "=== GNOME extensions ==="
  install_extensions

  log "=== Debloat ==="
  debloat_packages

  log "=== Snapper snapshot limits ==="
  configure_snapper_limits 6

  log "=== GNOME tweaks ==="
  apply_logout_tweaks

  ok "Configs, tweaks, extensions, and debloat complete"
}

main
