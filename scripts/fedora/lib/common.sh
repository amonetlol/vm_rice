#!/usr/bin/env bash
# Shared helpers for vm_rice Fedora/Cosmic scripts
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/vm_rice"
BUILD_DIR="${CACHE_DIR}/build"

# Colors
if [[ -t 1 ]] && command -v tput &>/dev/null && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  MAGENTA="$(tput setaf 5)"
  CYAN="$(tput setaf 6)"
  BOLD="$(tput bold)"
  RESET="$(tput sgr0)"
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' RESET=''
fi

log()   { printf '%s[*]%s %s\n' "$BLUE" "$RESET" "$*" >&2; }
ok()    { printf '%s[OK]%s %s\n' "$GREEN" "$RESET" "$*" >&2; }
warn()  { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
err()   { printf '%s[ERR]%s %s\n' "$RED" "$RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }

require_fedora() {
  [[ -f /etc/fedora-release ]] || die "This script requires Fedora Linux."
}

require_command() {
  local cmd="$1"
  command -v "$cmd" &>/dev/null || die "Required command not found: $cmd"
}

run_as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    if [[ -n "${VM_RICE_SUDO_PASS:-}" ]]; then
      printf '%s\n' "$VM_RICE_SUDO_PASS" | sudo -S "$@"
    else
      sudo "$@"
    fi
  else
    die "Root privileges required for: $*"
  fi
}

# When VM_RICE_SUDO_PASS is set, prepend a sudo wrapper for non-interactive SSH runs.
setup_noninteractive_sudo() {
  [[ -n "${VM_RICE_SUDO_PASS:-}" ]] || return 0
  local wrap_dir="${CACHE_DIR}/bin"
  mkdir -p "$wrap_dir"
  cat > "${wrap_dir}/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${VM_RICE_SUDO_PASS}" | /usr/bin/sudo -S "$@"
EOF
  chmod +x "${wrap_dir}/sudo"
  export PATH="${wrap_dir}:${PATH}"
}

setup_noninteractive_sudo

clone_or_update() {
  local url="$1"
  local name="$2"
  local dest="${BUILD_DIR}/${name}"

  mkdir -p "$BUILD_DIR"
  if [[ -d "${dest}/.git" ]]; then
    log "Updating ${name}..."
    git -C "$dest" pull --ff-only --quiet 2>/dev/null || git -C "$dest" fetch --quiet
  else
    log "Cloning ${name}..."
    rm -rf "$dest"
    git clone --depth 1 "$url" "$dest"
  fi
  printf '%s' "$dest"
}

dnf_pkg_installed() {
  local pkg="$1"
  rpm -q "$pkg" &>/dev/null
}

ensure_murrine_engine() {
  # Fedora: gtk-murrine-engine (Arch: gtk-engine-murrine)
  if dnf_pkg_installed gtk-murrine-engine; then
    return 0
  fi
  run_as_root dnf install -y gtk-murrine-engine 2>/dev/null \
    || warn "gtk-murrine-engine unavailable — legacy GTK2 rendering may be limited"
}

ensure_theme_build_deps() {
  log "Ensuring GTK theme build dependencies..."
  # Fedora: sassc + gtk2 theme helpers (no gnome-themes-extra package name)
  run_as_root dnf install -y sassc gtk2-engines adwaita-gtk2-theme 2>/dev/null \
    || warn "Some theme build deps missing — install sassc and gtk2-engines manually"
  ensure_murrine_engine
}

ensure_icon_build_deps() {
  log "Ensuring icon theme build dependencies..."
  ensure_murrine_engine
}

rand_pick() {
  local -n _arr=$1
  local len="${#_arr[@]}"
  (( len > 0 )) || return 1
  printf '%s' "${_arr[RANDOM % len]}"
}

apply_gtk_theme() {
  local theme="$1"
  # Cosmic uses GTK for apps; gsettings applies GTK theme (not GNOME Shell).
  gsettings set org.gnome.desktop.interface gtk-theme "$theme" 2>/dev/null || true
  gsettings set org.gnome.desktop.wm.preferences theme "$theme" 2>/dev/null || true
  ok "Applied GTK theme: ${theme} (use Cosmic Settings for shell appearance)"
}

apply_icon_theme() {
  local icon="$1"
  gsettings set org.gnome.desktop.interface icon-theme "$icon" 2>/dev/null || true
  ok "Applied icon theme: ${icon}"
}

apply_cursor_theme() {
  local cursor="${1:-Bibata-Modern-Classic}"
  gsettings set org.gnome.desktop.interface cursor-theme "$cursor" 2>/dev/null || true
  ok "Applied cursor theme: ${cursor}"
}
