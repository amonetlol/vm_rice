#!/usr/bin/env bash
# Install packages not in Fedora base repos (requires 1.repos.sh for RPM Fusion/Brave)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_fedora

if [[ ! -f /etc/yum.repos.d/rpmfusion-free.repo ]]; then
  warn "RPM Fusion not enabled — running 1.repos.sh first..."
  bash "${SCRIPT_DIR}/1.repos.sh"
fi

# Maps Arch AUR packages to Fedora equivalents where possible.
EXTRA_PACKAGES=(
  brave-browser
  ulauncher
)

log "Installing extra packages via dnf (continues on individual failures)..."
failed=()
for pkg in "${EXTRA_PACKAGES[@]}"; do
  log "Installing: ${pkg}"
  if run_as_root dnf install -y "$pkg" 2>/dev/null; then
    ok "Installed ${pkg}"
  else
    warn "Failed to install: ${pkg} (repo may be missing — run 1.repos.sh)"
    failed+=("$pkg")
  fi
done

# herdr-bin: no Fedora equivalent found — skip with notice
warn "Skipping herdr-bin (AUR-only; no Fedora package available)"

# blackbox-terminal: try flatpak as fallback (not in official Fedora repos)
if ! command -v blackbox-terminal &>/dev/null && ! command -v blackbox &>/dev/null; then
  log "Trying blackbox-terminal via flatpak..."
  if command -v flatpak &>/dev/null; then
    if flatpak install -y flathub com.raggesilver.BlackBox 2>/dev/null; then
      ok "Installed BlackBox terminal via flatpak"
    else
      warn "blackbox-terminal unavailable — install a terminal manually (e.g. cosmic-term, alacritty)"
      failed+=(blackbox-terminal)
    fi
  else
    warn "flatpak not available — skipping blackbox-terminal"
    failed+=(blackbox-terminal)
  fi
else
  ok "Blackbox terminal already available"
fi

if ((${#failed[@]} > 0)); then
  warn "Some extra packages failed: ${failed[*]}"
else
  ok "All extra packages installed"
fi
