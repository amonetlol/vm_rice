#!/usr/bin/env bash
# Install pacman packages for vm_rice
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_arch

PACKAGES=(
  base-devel git wget curl unzip zip p7zip tar rsync
  nano vim neovim bash-completion procs less
  starship zoxide eza fd ripgrep fzf duf fastfetch btop htop tree tldr lazygit bat
  gcc make cmake pkgconf jq bc findutils coreutils
  intel-ucode snap-pac
  nodejs npm lua51 luarocks python python-pip python-pynvim python-pipenv
  tree-sitter-cli python-virtualenv prettier
  fontconfig noto-fonts noto-fonts-emoji
  xdg-utils xdg-user-dirs xdg-user-dirs-gtk
  networkmanager network-manager-applet openssh inetutils open-vm-tools fuse2 gtkmm3 mesa
  ttf-0xproto-nerd extension-manager gnome-tweaks
)

log "Installing ${#PACKAGES[@]} pacman packages..."
run_as_root pacman -Syu --noconfirm
run_as_root pacman -S --needed --noconfirm "${PACKAGES[@]}"
ok "Pacman packages installed"
