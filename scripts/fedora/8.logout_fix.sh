#!/usr/bin/env bash
# GNOME logout button fix — NOT APPLICABLE to Cosmic DE
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_fedora

log "Skipping GNOME logout fix — Cosmic DE uses its own power menu (Super+Shift+Escape for logout)"
ok "No action needed for Cosmic DE"
