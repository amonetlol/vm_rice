#!/usr/bin/env bash
# GNOME logout button visibility fix
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_arch

log "Enabling always-show-log-out in GNOME Shell..."

if gsettings writable org.gnome.shell always-show-log-out &>/dev/null; then
  gsettings set org.gnome.shell always-show-log-out true
  ok "gsettings: org.gnome.shell always-show-log-out=true"
else
  warn "gsettings key org.gnome.shell always-show-log-out not writable (extension may be required)"
fi

if command -v dconf &>/dev/null; then
  dconf write /org/gnome/shell/always-show-log-out true 2>/dev/null && \
  ok "dconf: /org/gnome/shell/always-show-log-out=true" || \
  warn "dconf write failed — key may require a GNOME Shell extension"
fi

ok "Logout fix applied"
