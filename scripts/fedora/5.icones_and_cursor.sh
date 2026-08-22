#!/usr/bin/env bash
# Install icon themes and cursor themes (Bibata, Qogir)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/icons.sh
source "${SCRIPT_DIR}/lib/icons.sh"

require_fedora

install_all_icons
ok "Icon themes and cursor installed"
