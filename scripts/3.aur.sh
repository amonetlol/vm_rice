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
  blackbox-terminal
)

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

if ((${#failed[@]} > 0)); then
  warn "Some AUR packages failed: ${failed[*]}"
else
  ok "All AUR packages installed"
fi
