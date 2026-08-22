#!/usr/bin/env bash
# Install GTK themes with specified variants
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/themes.sh
source "${SCRIPT_DIR}/lib/themes.sh"

require_fedora

install_all_themes
ok "All GTK themes installed to ~/.themes"
