#!/usr/bin/env bash
# Icon theme metadata for vm_rice (sourced, not executed)
set -euo pipefail

ICON_DEST="${HOME}/.local/share/icons"
mkdir -p "$ICON_DEST"

declare -A ICON_REPOS=(
  [mcmojave]="https://github.com/vinceliuice/McMojave-circle"
  [gruvbox_plus]="https://github.com/SylEleuth/gruvbox-plus-icon-pack"
  [mcmuse_circle]="https://github.com/yeyushengfan258/McMuse-circle"
  [hatter]="https://github.com/Mibea/Hatter"
  [mcmuse]="https://github.com/yeyushengfan258/McMuse-icon-theme"
)

# gsettings icon theme names per pack / variant
declare -A ICON_VARIANTS=(
  [mcmojave_blue]="McMojave-circle-blue"
  [mcmojave_green]="McMojave-circle-green"
  [mcmojave_brown]="McMojave-circle-brown"
  [mcmojave_grey]="McMojave-circle-grey"
  [mcmojave_black]="McMojave-circle-black"
  [mcmojave_light_blue]="McMojave-circle-blue"
  [gruvbox_blue]="Gruvbox-Plus-Dark"
  [gruvbox_jade]="Gruvbox-Plus-Dark"
  [gruvbox_sapphire]="Gruvbox-Plus-Dark"
  [gruvbox_black]="Gruvbox-Plus-Dark"
  [gruvbox_grey]="Gruvbox-Plus-Dark"
  [gruvbox_citron]="Gruvbox-Plus-Dark"
  [gruvbox_caramel]="Gruvbox-Plus-Dark"
  [gruvbox_olive]="Gruvbox-Plus-Dark"
  [gruvbox_green]="Gruvbox-Plus-Dark"
  [mcmuse_circle_blue]="McMuse-circle-blue"
  [mcmuse_circle_grey]="McMuse-circle-grey"
  [mcmuse_circle_black]="McMuse-circle-black"
  [hatter_blue]="Hatter-Blue"
  [hatter_green]="Hatter-Green"
  [hatter_slate]="Hatter-Slate"
  [hatter_teal]="Hatter-Teal"
  [mcmuse_blue]="McMuse-blue"
  [mcmuse_grey]="McMuse-grey"
  [mcmuse_black]="McMuse-black"
)

ICON_COMBOS=(
  mcmojave_blue mcmojave_green mcmojave_brown mcmojave_grey mcmojave_black
  gruvbox_blue gruvbox_jade gruvbox_sapphire gruvbox_black gruvbox_grey
  gruvbox_citron gruvbox_caramel gruvbox_olive gruvbox_green
  mcmuse_circle_blue mcmuse_circle_grey mcmuse_circle_black
  hatter_blue hatter_green hatter_slate hatter_teal
  mcmuse_blue mcmuse_grey mcmuse_black
)

install_mcmojave_icons() {
  local dest
  dest="$(clone_or_update "${ICON_REPOS[mcmojave]}" McMojave-circle)"
  ensure_icon_build_deps
  pushd "$dest" >/dev/null
  chmod +x install.sh
  ./install.sh -a -t blue green brown grey black || warn "McMojave-circle install had issues"
  popd >/dev/null
  ok "McMojave-circle icons installed"
}

install_gruvbox_plus_icons() {
  local dest colors color
  dest="$(clone_or_update "${ICON_REPOS[gruvbox_plus]}" gruvbox-plus-icon-pack)"
  mkdir -p "$ICON_DEST"
  for pack in Gruvbox-Plus-Dark Gruvbox-Plus-Light; do
  if [[ -d "${dest}/${pack}" ]]; then
    rm -rf "${ICON_DEST}/${pack}"
    cp -a "${dest}/${pack}" "${ICON_DEST}/"
  fi
  done
  colors=(blue jade sapphire black grey citron caramel olive green)
  if [[ -x "${dest}/scripts/folders-color-chooser" ]]; then
  chmod +x "${dest}/scripts/folders-color-chooser"
  for color in "${colors[@]}"; do
    "${dest}/scripts/folders-color-chooser" --color="$color" || warn "Gruvbox folder color ${color} failed"
  done
  fi
  ok "Gruvbox-Plus icons installed"
}

install_mcmuse_circle_icons() {
  local dest
  dest="$(clone_or_update "${ICON_REPOS[mcmuse_circle]}" McMuse-circle)"
  pushd "$dest" >/dev/null
  chmod +x install.sh
  ./install.sh -blue -grey -black || ./install.sh -a || warn "McMuse-circle install had issues"
  popd >/dev/null
  ok "McMuse-circle icons installed"
}

install_hatter_icons() {
  local dest variants variant
  dest="$(clone_or_update "${ICON_REPOS[hatter]}" Hatter)"
  variants=(Hatter-Blue Hatter-Green Hatter-Slate Hatter-Teal)
  for variant in "${variants[@]}"; do
  if [[ -d "${dest}/${variant}" ]]; then
    rm -rf "${ICON_DEST}/${variant}"
    cp -a "${dest}/${variant}" "${ICON_DEST}/"
  fi
  done
  ok "Hatter icons installed (blue, green, slate, teal)"
}

install_mcmuse_icons() {
  local dest
  dest="$(clone_or_update "${ICON_REPOS[mcmuse]}" McMuse-icon-theme)"
  pushd "$dest" >/dev/null
  chmod +x install.sh
  ./install.sh -blue -grey -black || ./install.sh -a || warn "McMuse-icon-theme install had issues"
  popd >/dev/null
  ok "McMuse-icon-theme installed"
}

install_bibata_cursor() {
  if pacman -Qi bibata-cursor-theme &>/dev/null; then
  ok "bibata-cursor-theme already installed (pacman)"
  elif command -v yay &>/dev/null && yay -Qi bibata-cursor-theme &>/dev/null; then
  ok "bibata-cursor-theme already installed (AUR)"
  elif command -v yay &>/dev/null; then
  log "Installing bibata-cursor-theme via yay..."
  yay -S --needed --noconfirm bibata-cursor-theme
  else
  warn "yay not found; install bibata-cursor-theme manually"
  fi
}

install_qogir_cursor() {
  if pacman -Qi qogir-cursor-theme &>/dev/null; then
  ok "qogir-cursor-theme already installed (pacman)"
  elif command -v yay &>/dev/null && yay -Qi qogir-cursor-theme &>/dev/null; then
  ok "qogir-cursor-theme already installed (AUR)"
  elif command -v yay &>/dev/null; then
  log "Installing qogir-cursor-theme via yay..."
  yay -S --needed --noconfirm qogir-cursor-theme
  else
  warn "yay not found; install qogir-cursor-theme manually"
  fi
}

install_cursor_themes() {
  install_bibata_cursor
  install_qogir_cursor
}

CURSOR_THEMES=(
  Bibata-Modern-Classic
  Qogir-cursors
)

install_all_icons() {
  install_mcmojave_icons
  install_gruvbox_plus_icons
  install_mcmuse_circle_icons
  install_hatter_icons
  install_mcmuse_icons
  install_cursor_themes
}

apply_random_icon() {
  local combo icon_name
  combo="$(rand_pick ICON_COMBOS)"
  log "Applying random icon combo: ${combo}"
  case "$combo" in
  mcmojave_*) install_mcmojave_icons ;;
  gruvbox_*) install_gruvbox_plus_icons ;;
  mcmuse_circle_*) install_mcmuse_circle_icons ;;
  hatter_*) install_hatter_icons ;;
  mcmuse_*) install_mcmuse_icons ;;
  esac
  install_cursor_themes
  icon_name="${ICON_VARIANTS[$combo]:-${combo}}"
  apply_icon_theme "$icon_name"
  apply_cursor_theme "$(rand_pick CURSOR_THEMES)"
}

apply_icon_combo() {
  local combo="$1"
  local icon_name="${ICON_VARIANTS[$combo]:-}"
  [[ -n "$icon_name" ]] || die "Unknown icon combo: ${combo}"
  case "$combo" in
  mcmojave_*) install_mcmojave_icons ;;
  gruvbox_*) install_gruvbox_plus_icons ;;
  mcmuse_circle_*) install_mcmuse_circle_icons ;;
  hatter_*) install_hatter_icons ;;
  mcmuse_*) install_mcmuse_icons ;;
  esac
  install_cursor_themes
  apply_icon_theme "$icon_name"
  apply_cursor_theme "Bibata-Modern-Classic"
}
