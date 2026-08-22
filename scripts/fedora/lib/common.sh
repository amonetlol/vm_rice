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

# Install dnf packages; bulk first, then per-package retry. Returns 1 only when strict=1 and any fail.
dnf_install_packages() {
  local strict="${1:-0}"
  shift
  local -a packages=("$@")
  local pkg failed=()

  log "Installing ${#packages[@]} dnf packages..."
  if run_as_root dnf install -y "${packages[@]}"; then
    ok "All dnf packages installed"
    return 0
  fi

  warn "Bulk dnf install failed — retrying packages individually..."
  for pkg in "${packages[@]}"; do
    if run_as_root dnf install -y "$pkg"; then
      ok "Installed ${pkg}"
    else
      warn "Package not available: ${pkg}"
      failed+=("$pkg")
    fi
  done

  if ((${#failed[@]} > 0)); then
    warn "Some packages unavailable: ${failed[*]}"
    [[ "$strict" == "1" ]] && return 1
  fi
  return 0
}

ensure_starship() {
  if command -v starship &>/dev/null; then
    ok "starship already installed"
    return 0
  fi

  log "Installing starship via COPR (atim/starship)..."
  if run_as_root dnf copr enable -y atim/starship \
    && run_as_root dnf install -y starship; then
    ok "starship installed from COPR atim/starship"
    return 0
  fi

  warn "COPR install failed; falling back to official install script..."
  local bin_dir="${HOME}/.local/bin"
  mkdir -p "$bin_dir"
  if curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$bin_dir"; then
    ok "starship installed to ${bin_dir}"
  else
    warn "starship install failed — try: dnf copr enable atim/starship && dnf install starship"
    return 1
  fi
}

ensure_pipenv() {
  if command -v pipenv &>/dev/null; then
    ok "pipenv already available"
    return 0
  fi

  log "Installing pipenv via pip (not in Fedora 44 repos)..."
  if python3 -m pip install --user pipenv; then
    ok "pipenv installed via pip --user"
  else
    warn "pipenv install failed — try: python3 -m pip install --user pipenv"
    return 1
  fi
}

ensure_dnf_config_manager() {
  if dnf config-manager --help &>/dev/null; then
    return 0
  fi
  log "Installing DNF config-manager plugin..."
  run_as_root dnf install -y dnf5-plugins 2>/dev/null \
    || run_as_root dnf install -y dnf-plugins-core
}

# Add a .repo file from URL. Supports DNF5, DNF4, and direct download fallback.
add_dnf_repo_from_url() {
  local url="$1"
  local save_name="${2:-$(basename "$url")}"

  [[ "$save_name" == *.repo ]] || save_name="${save_name}.repo"
  local dest="/etc/yum.repos.d/${save_name}"

  if [[ -f "$dest" ]]; then
    return 0
  fi

  ensure_dnf_config_manager

  if run_as_root dnf config-manager addrepo \
      --from-repofile="$url" --save-filename="$save_name"; then
    return 0
  fi

  if run_as_root dnf config-manager --add-repo "$url"; then
    return 0
  fi

  require_command curl
  log "config-manager failed; downloading repo file directly to ${dest}"
  run_as_root curl -fsSL "$url" -o "$dest"
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
  # Fedora: sassc + gtk2-engines; gnome-themes-extra (GTK2 Adwaita) removed from Fedora 44+
  run_as_root dnf install -y sassc gtk2-engines 2>/dev/null \
    || warn "Some theme build deps missing — install sassc and gtk2-engines manually"
  if ! run_as_root dnf install -y gnome-themes-extra 2>/dev/null; then
    warn "gnome-themes-extra/adwaita-gtk2-theme unavailable (GTK2 EOL in Fedora 44+)"
  fi
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
