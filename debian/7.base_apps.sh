#!/usr/bin/env bash
# Base Debian packages + CLI binaries (Arch names mapped to Debian)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_sudo "$@"
detect_real_user
export HOME="$REAL_HOME"
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

log "Installing base packages and CLI tools (Debian Sid)"

ensure_contrib_nonfree "$@"

apt-get install -y curl wget ca-certificates gnupg

APT_PKGS=(
  build-essential
  git wget curl unzip zip p7zip-full tar rsync nano vim neovim bash-completion
  less
  ripgrep fzf htop tree
  gcc make cmake pkg-config jq bc findutils coreutils
  intel-microcode
  nodejs npm
  lua5.1 luarocks
  python3 python3-pip python3-pynvim pipenv python3-venv
  fontconfig fonts-noto fonts-noto-color-emoji
  xdg-utils xdg-user-dirs xdg-user-dirs-gtk
  network-manager network-manager-applet nm-connection-editor
  openssh-client openssh-server
  inetutils-ping inetutils-traceroute
  open-vm-tools open-vm-tools-desktop
  gnome-shell gdm3 xserver-xorg-core xserver-common x11-xkb-utils xfonts-base
  libgtkmm-3.0-1v5 mesa-utils libgl1-mesa-dri
  fonts-0xproto
  gnome-tweaks gnome-shell-extension-manager
  nautilus
  wmctrl
  dconf-cli gsettings-desktop-schemas
  bat fd-find
)

log "Installing apt packages..."
set +e
apt-get install -y --no-install-recommends "${APT_PKGS[@]}"
APT_RC=$?
set -e

if [[ $APT_RC -ne 0 ]]; then
  warn "apt-get returned $APT_RC — retrying packages individually..."
  for pkg in "${APT_PKGS[@]}"; do
    apt-get install -y --no-install-recommends "$pkg" 2>/dev/null || warn "failed: $pkg"
  done
fi
ok "Apt packages installed"

# libfuse2t64 or libfuse3-4 (AppImage compat)
if ! dpkg -l libfuse2t64 libfuse2 libfuse3-4 2>/dev/null | grep -q '^ii'; then
  log "Installing libfuse..."
  apt-get install -y libfuse2t64 2>/dev/null || \
    apt-get install -y libfuse3-4 2>/dev/null || {
      warn "Fallback: libfuse2 from Bookworm pool"
      for url in \
        "http://deb.debian.org/debian/pool/main/f/fuse/libfuse2_2.9.9-8+b1_amd64.deb" \
        "http://ftp.debian.org/debian/pool/main/f/fuse/libfuse2_2.9.9-6+b1_amd64.deb"; do
        curl -fsSL -o /tmp/libfuse2.deb "$url" && break
      done
      dpkg -i /tmp/libfuse2.deb 2>/dev/null || apt-get install -f -y
      rm -f /tmp/libfuse2.deb
    }
fi

# ulauncher (not in Debian apt)
if ! command -v ulauncher &>/dev/null; then
  log "Installing ulauncher..."
  apt-get install -y python3-gi gir1.2-webkit2-4.1 python3-dbus 2>/dev/null || \
    apt-get install -y python3-gi gir1.2-webkit2-4.0 python3-dbus
  set +e
  for url in \
    "https://github.com/Ulauncher/Ulauncher/releases/download/v6.0.0-beta32/ulauncher_6.0.0.beta32_all.deb" \
    "https://github.com/Ulauncher/Ulauncher/releases/download/release_5.15.11/ulauncher_5.15.11_all.deb"; do
    curl -fsSL -o /tmp/ulauncher_all.deb "$url" && break
  done
  set -e
  if [[ -f /tmp/ulauncher_all.deb ]]; then
    dpkg -i /tmp/ulauncher_all.deb || apt-get install -f -y
    rm -f /tmp/ulauncher_all.deb
    ok "ulauncher installed"
  else
    warn "Failed to download ulauncher"
  fi
fi

# fd-find -> fd, batcat -> bat
if [[ -x /usr/bin/fdfind && ! -e /usr/local/bin/fd ]]; then
  ln -sf /usr/bin/fdfind /usr/local/bin/fd
  ok "Symlinked fd -> fdfind"
fi
if [[ -x /usr/bin/batcat && ! -e /usr/local/bin/bat ]]; then
  ln -sf /usr/bin/batcat /usr/local/bin/bat
  ok "Symlinked bat -> batcat"
fi

# tree-sitter-cli (GitHub binary)
if ! command -v tree-sitter &>/dev/null; then
  log "Installing tree-sitter CLI..."
  set +e
  for url in \
    "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.11/tree-sitter-linux-x64.gz" \
    "https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.8/tree-sitter-linux-x64.tar.gz"; do
    if [[ "$url" == *.gz && "$url" != *.tar.gz ]]; then
      curl -fsSL -o /tmp/tree-sitter.gz "$url" && gunzip -c /tmp/tree-sitter.gz > /tmp/tree-sitter && break
    else
      curl -fsSL -o /tmp/tree-sitter.tar.gz "$url" && tar -xzf /tmp/tree-sitter.tar.gz -C /tmp tree-sitter && break
    fi
  done
  set -e
  if [[ -f /tmp/tree-sitter ]]; then
    chmod +x /tmp/tree-sitter
    mv /tmp/tree-sitter /usr/local/bin/tree-sitter
    rm -f /tmp/tree-sitter.gz /tmp/tree-sitter.tar.gz
    ok "tree-sitter installed"
  else
    warn "Failed to download tree-sitter"
  fi
fi

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# starship
if ! command -v starship &>/dev/null; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  ok "starship installed"
fi

# zoxide
if ! command -v zoxide &>/dev/null; then
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  ok "zoxide installed"
fi

# eza
if ! command -v eza &>/dev/null; then
  set +e
  for url in \
    "https://github.com/eza-community/eza/releases/download/v0.23.5/eza_x86_64-unknown-linux-gnu.tar.gz" \
    "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"; do
    curl -fsSL -o /tmp/eza.tar.gz "$url" && tar -xzf /tmp/eza.tar.gz -C /tmp && break
  done
  set -e
  if [[ -x /tmp/eza ]]; then
    mv /tmp/eza /usr/local/bin/eza
    rm -f /tmp/eza.tar.gz
    ok "eza installed"
  else
    warn "Failed to download eza"
  fi
fi

# procs
if ! command -v procs &>/dev/null; then
  PROCS_VER="0.14.8"
  if curl -fsSL -o /tmp/procs.zip "https://github.com/dalance/procs/releases/download/v${PROCS_VER}/procs-v${PROCS_VER}-x86_64-linux.zip"; then
    unzip -qo /tmp/procs.zip -d /tmp
    mv /tmp/procs /usr/local/bin/procs
    rm -f /tmp/procs.zip
    ok "procs installed"
  else
    warn "Failed to download procs"
  fi
fi

# duf
if ! command -v duf &>/dev/null; then
  DUF_VER="0.9.1"
  if curl -fsSL -o /tmp/duf.tar.gz "https://github.com/muesli/duf/releases/download/v${DUF_VER}/duf_${DUF_VER}_linux_x86_64.tar.gz"; then
    tar -xzf /tmp/duf.tar.gz -C /tmp duf 2>/dev/null || tar -xzf /tmp/duf.tar.gz -C /tmp
    mv /tmp/duf /usr/local/bin/duf
    rm -f /tmp/duf.tar.gz
    ok "duf installed"
  else
    warn "Failed to download duf"
  fi
fi

# fastfetch
if ! command -v fastfetch &>/dev/null; then
  for url in \
    "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb" \
    "https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-amd64.deb"; do
    curl -fsSL -o /tmp/fastfetch.deb "$url" && break
  done
  if [[ -f /tmp/fastfetch.deb ]]; then
    dpkg -i /tmp/fastfetch.deb || apt-get install -f -y
    rm -f /tmp/fastfetch.deb
    ok "fastfetch installed"
  else
    warn "Failed to download fastfetch"
  fi
fi

# btop
if ! command -v btop &>/dev/null; then
  apt-get install -y btop 2>/dev/null || {
    BTOP_VER="1.4.0"
    curl -fsSL -o /tmp/btop.tar.gz "https://github.com/aristocratos/btop/releases/download/v${BTOP_VER}/btop-x86_64-linux-musl.tbz"
    tar -xjf /tmp/btop.tar.gz -C /tmp
    make -C /tmp/btop install PREFIX=/usr/local
    rm -rf /tmp/btop /tmp/btop.tar.gz
  }
  ok "btop installed"
fi

# lazygit
if ! command -v lazygit &>/dev/null; then
  LG_VER="0.49.0"
  if curl -fsSL -o /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_x86_64.tar.gz"; then
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    mv /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit.tar.gz
    ok "lazygit installed"
  else
    warn "Failed to download lazygit"
  fi
fi

# tldr via tealdeer or binary
if ! command -v tldr &>/dev/null; then
  apt-get install -y tealdeer 2>/dev/null || {
    TLDR_VER="1.6.1"
    curl -fsSL -o /tmp/tealdeer.tar.gz "https://github.com/tealdeer-rs/tealdeer/releases/download/v${TLDR_VER}/tealdeer-v${TLDR_VER}-x86_64-unknown-linux-musl.tar.gz"
    tar -xzf /tmp/tealdeer.tar.gz -C /tmp
    mv /tmp/tealdeer /usr/local/bin/tldr
    rm -f /tmp/tealdeer.tar.gz
  }
  ok "tldr/tealdeer installed"
fi

# prettier (global npm)
if ! command -v prettier &>/dev/null; then
  npm install -g prettier 2>/dev/null || sudo -u "$REAL_USER" npm install -g prettier --prefix "$HOME/.local" || true
fi

# Nerd font 0xproto
NERD_DIR="$HOME/.local/share/fonts/0xProto"
if [[ ! -d "$NERD_DIR" ]]; then
  log "Installing 0xProto Nerd Font..."
  mkdir -p "$NERD_DIR"
  curl -fsSL -o /tmp/0xproto-nerd.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip"
  unzip -qo /tmp/0xproto-nerd.zip -d "$NERD_DIR"
  rm -f /tmp/0xproto-nerd.zip
  fc-cache -fv "$HOME/.local/share/fonts" 2>/dev/null || true
  chown -R "$REAL_USER:$REAL_USER" "$HOME/.local/share/fonts" 2>/dev/null || true
  ok "0xProto Nerd Font installed"
fi

chown -R "$REAL_USER:$REAL_USER" "$HOME/.local" 2>/dev/null || true

ok "Base packages and CLI tools installed"