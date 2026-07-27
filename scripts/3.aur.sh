#!/usr/bin/env bash
# Install AUR packages (requires yay from 1.yay.sh)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_arch

if ! command -v yay &>/dev/null; then
  warn "yay not found — running 1.yay.sh first..."
  bash "${SCRIPT_DIR}/1.yay.sh"
fi

AUR_PACKAGES=(
  yay-bin
  herdr-bin
  brave-origin-bin
  bibata-cursor-theme-bin
  qogir-cursor-theme
)

install_blackbox() {
  if command -v blackbox &>/dev/null || command -v blackbox-terminal &>/dev/null; then
    ok "Blackbox terminal already installed"
    return 0
  fi
  if flatpak info com.raggesilver.BlackBox &>/dev/null 2>&1; then
    ok "Blackbox flatpak already installed"
    return 0
  fi

  log "Installing Blackbox via Flatpak (AUR blackbox-terminal build is currently broken)..."
  run_as_root pacman -S --needed --noconfirm flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  run_as_root flatpak install -y flathub com.raggesilver.BlackBox \
    || warn "Flatpak Blackbox install failed — keybinds will fall back to gnome-terminal"
}

log "Installing AUR packages (continues on individual failures)..."
failed=()
for pkg in "${AUR_PACKAGES[@]}"; do
  log "Installing AUR package: ${pkg}"
  if yay -S --needed --noconfirm \
      --answerdiff None --answerclean None --removemake \
      "$pkg"; then
    ok "Installed ${pkg}"
  else
    warn "Failed to install AUR package: ${pkg}"
    failed+=("$pkg")
  fi
done

install_blackbox

if ((${#failed[@]} > 0)); then
  warn "Some AUR packages failed: ${failed[*]}"
else
  ok "All AUR packages installed"
fi
