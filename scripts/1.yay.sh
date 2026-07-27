#!/usr/bin/env bash
# Install yay-bin from AUR
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_arch

if command -v yay &>/dev/null; then
  ok "yay is already installed: $(yay --version | head -1)"
  exit 0
fi

log "Installing build dependencies for yay..."
run_as_root pacman -S --needed --noconfirm base-devel git

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

log "Cloning yay-bin from AUR..."
git clone https://aur.archlinux.org/yay-bin.git "${tmpdir}/yay-bin"

pushd "${tmpdir}/yay-bin" >/dev/null
makepkg -si --noconfirm
popd >/dev/null

command -v yay &>/dev/null || die "yay installation failed"
ok "yay installed successfully"
