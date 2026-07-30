#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_sudo "$@"
detect_real_user
export HOME="$REAL_HOME"

export DEBIAN_FRONTEND=noninteractive

log "Installing desktop apps"

apt-get install -y curl wget ca-certificates gnupg

# Brave — sources.list must be ONLY stable main
if [[ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]]; then
  log "Adding Brave browser apt repository..."
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    | tee /etc/apt/sources.list.d/brave-browser-release.list
  apt-get update -y
  ok "Brave repository added"
else
  log "Brave repository already present"
fi

apt-get install -y --no-install-recommends brave-browser blackbox-terminal

# herdr binary from GitHub releases
if ! command -v herdr &>/dev/null; then
  HERDR_VER="0.7.5"
  log "Installing herdr v${HERDR_VER}..."
  if curl -fsSL -o /tmp/herdr "https://github.com/herdrdev/herdr/releases/download/v${HERDR_VER}/herdr-linux-x86_64"; then
    chmod +x /tmp/herdr
    mv /tmp/herdr /usr/local/bin/herdr
    ok "herdr installed"
  else
    warn "Failed to download herdr"
  fi
else
  ok "herdr already installed"
fi

ok "Desktop apps installed"