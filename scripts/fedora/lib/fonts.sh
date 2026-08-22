#!/usr/bin/env bash
# Custom nerd font install (amonetlol/dot → ~/.local/share/fonts)
set -euo pipefail

DOT_CACHE="${DOT_CACHE:-${HOME}/.cache/base-dot-repo}"
DOT_REPO="${DOT_REPO:-https://github.com/amonetlol/dot.git}"
FONT_SRC="${DOT_CACHE}/dotfiles/fonts/.fonts"
FONT_DEST="${HOME}/.local/share/fonts"
LEGACY_FONT_DEST="${HOME}/.fonts"

ensure_dot_repo() {
  if [[ -d "${DOT_CACHE}/.git" ]]; then
    log "Updating dot repo cache..."
    git -C "$DOT_CACHE" pull --ff-only --quiet 2>/dev/null \
      || git -C "$DOT_CACHE" fetch --quiet 2>/dev/null \
      || warn "dot repo update failed — using cached copy"
    return 0
  fi

  log "Cloning ${DOT_REPO}..."
  mkdir -p "$(dirname "$DOT_CACHE")"
  git clone --depth 1 "$DOT_REPO" "$DOT_CACHE"
}

copy_font_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  if command -v rsync &>/dev/null; then
    rsync -a "${src}/" "${dest}/"
  else
    cp -a "${src}/." "${dest}/"
  fi
}

install_custom_nerd_fonts() {
  ensure_dot_repo

  if [[ ! -d "$FONT_SRC" ]]; then
    warn "Custom nerd fonts missing at ${FONT_SRC}"
    return 1
  fi

  log "Installing custom nerd fonts to ${FONT_DEST}..."
  copy_font_tree "$FONT_SRC" "$FONT_DEST"
  copy_font_tree "$FONT_SRC" "$LEGACY_FONT_DEST"

  local count
  count="$(find "$FONT_DEST" -type f | wc -l)"
  fc-cache -fv "$FONT_DEST" 2>/dev/null || fc-cache -fv
  ok "Custom nerd fonts installed (${count} files in ${FONT_DEST})"
}
