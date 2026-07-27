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
  blackbox-terminal
  bibata-cursor-theme
  qogir-cursor-theme
)

log "Installing AUR packages: ${AUR_PACKAGES[*]}"
# yay-bin may already be installed; --needed skips reinstall
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
ok "AUR packages installed"
