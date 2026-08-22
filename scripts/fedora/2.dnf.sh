#!/usr/bin/env bash
# Install dnf packages for vm_rice (Fedora/Cosmic)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_fedora

# Fedora package names differ from Arch; GNOME-specific packages removed for Cosmic DE.
PACKAGES=(
  @development-tools git wget curl unzip zip p7zip p7zip-plugins tar rsync
  nano vim neovim bash-completion util-linux procps-ng less
  starship zoxide eza fd-find ripgrep fzf duf fastfetch btop htop tree tealdeer bat
  gcc gcc-c++ make cmake pkgconf-pkg-config jq bc findutils coreutils
  microcode_ctl
  nodejs npm lua luarocks python3 python3-pip python3-pynvim python3-pipenv
  python3-virtualenv tree-sitter-cli
  fontconfig google-noto-sans-vf-fonts google-noto-emoji-fonts
  xdg-utils xdg-user-dirs xdg-user-dirs-gtk
  NetworkManager openssh-clients open-vm-tools fuse fuse-libs gtkmm3.0 mesa-libGL
  sassc gtk-murrine-engine gtk2-engines adwaita-gtk2-theme
  flatpak
)

OPTIONAL_PACKAGES=(
  # Nerd font may be in COPR; install if available, skip otherwise
  0xproto-nerd-fonts
)

log "Installing ${#PACKAGES[@]} dnf packages..."
run_as_root dnf upgrade -y
run_as_root dnf install -y "${PACKAGES[@]}"

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  if run_as_root dnf install -y "$pkg" 2>/dev/null; then
    ok "Installed optional package: ${pkg}"
  else
    warn "Optional package not available: ${pkg} (try COPR or manual install)"
  fi
done

ok "Dnf packages installed"
