#!/usr/bin/env bash
# Shared helpers for Debian setup scripts
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_CACHE="${DOT_CACHE:-$HOME/.cache/dot-setup}"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }
die()  { printf '[!] %s\n' "$*" >&2; exit 1; }

detect_real_user() {
  if [[ -n "${REAL_USER:-}" ]]; then
    return 0
  fi
  if [[ "${EUID:-$(id -u)}" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    REAL_USER="$SUDO_USER"
  else
    REAL_USER="${USER:-$(whoami)}"
  fi
  REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
  [[ -n "$REAL_HOME" ]] || die "Could not resolve home for user: $REAL_USER"
}

require_sudo() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    exec sudo -E bash "$0" "$@"
  fi
}

run_as_user() {
  detect_real_user
  if [[ "$(id -u)" -eq 0 ]]; then
    sudo -u "$REAL_USER" -H bash -lc "$*"
  else
    bash -lc "$*"
  fi
}

user_dbus() {
  detect_real_user
  local uid
  uid="$(id -u "$REAL_USER")"
  printf 'unix:path=/run/user/%s/bus' "$uid"
}

run_gsettings() {
  detect_real_user
  local dbus
  dbus="$(user_dbus)"
  if [[ "$(id -u)" -eq 0 ]]; then
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="$dbus" gsettings "$@" 2>/dev/null || \
      sudo -u "$REAL_USER" gsettings "$@" 2>/dev/null || true
  else
    DBUS_SESSION_BUS_ADDRESS="$dbus" gsettings "$@" 2>/dev/null || gsettings "$@" 2>/dev/null || true
  fi
}

run_dconf() {
  detect_real_user
  local dbus
  dbus="$(user_dbus)"
  if [[ "$(id -u)" -eq 0 ]]; then
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="$dbus" dconf "$@" 2>/dev/null || \
      sudo -u "$REAL_USER" dconf "$@" 2>/dev/null || true
  else
    DBUS_SESSION_BUS_ADDRESS="$dbus" dconf "$@" 2>/dev/null || dconf "$@" 2>/dev/null || true
  fi
}

ensure_dot_cache() {
  detect_real_user
  mkdir -p "$DOT_CACHE"
  if [[ "$(id -u)" -eq 0 ]]; then
    chown -R "$REAL_USER:$REAL_USER" "$DOT_CACHE"
  fi
}

clone_or_update() {
  local url="$1" dest="$2"
  detect_real_user
  if [[ -d "$dest/.git" ]]; then
    log "Updating $(basename "$dest")..."
    run_as_user "git -C '$dest' pull --ff-only" 2>/dev/null || true
  else
    log "Cloning $(basename "$dest")..."
    run_as_user "git clone --depth=1 '$url' '$dest'"
  fi
}

cleanup_icon_dirs() {
  local dir
  for dir in "$HOME/.icons" "$HOME/.local/share/icons"; do
    [[ -d "$dir" ]] || continue
    find "$dir" -maxdepth 1 -mindepth 1 -type d \( -iname '*ubuntu*' -o -iname '*manjaro*' \) -print0 2>/dev/null | \
      while IFS= read -r -d '' item; do
        log "Removing unwanted icon folder: $item"
        rm -rf "$item"
      done
  done
}

ensure_contrib_nonfree() {
  require_sudo "$@"
  log "Ensuring contrib/non-free on Debian repos only..."
  sed -i -E \
    -e '/deb\.debian\.org|security\.debian\.org/{
      s/ main non-free-firmware$/ main contrib non-free non-free-firmware/
      s/ main$/ main contrib non-free non-free-firmware/
      s/ main contrib non-free non-free-firmware contrib non-free non-free-firmware/ main contrib non-free non-free-firmware/
    }' /etc/apt/sources.list
  local f
  for f in /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/*.list; do
    [[ -f "$f" ]] || continue
    case "$f" in
      *brave*|*docker*|*google*|*microsoft*|*vscode*|*cursor*|*nodesource*|*virtualbox*|*oracle*)
        sed -i -E 's/ main contrib non-free non-free-firmware/ main/g' "$f"
        sed -i -E 's/ stable main contrib non-free non-free-firmware/ stable main/g' "$f"
        continue
        ;;
    esac
    sed -i -E \
      -e '/deb\.debian\.org|security\.debian\.org/{
        s/ main non-free-firmware$/ main contrib non-free non-free-firmware/
        s/ main$/ main contrib non-free non-free-firmware/
      }' "$f" 2>/dev/null || true
  done
  apt-get update -y
  ok "Debian sources updated"
}