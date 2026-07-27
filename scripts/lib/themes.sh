#!/usr/bin/env bash
# Theme metadata for vm_rice (sourced, not executed)
set -euo pipefail

# Accent colors used by Fausto-Korpsvart themes (default = base/blue accent)
FAUSTO_COLORS=(default green grey teal)

# Theme families for random selection: name|repo_url|installer_type|schemes...
# installer_type: fausto | catppuccin | juno
declare -A THEME_REPOS=(
  [everforest]="https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme"
  [kanagawa]="https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme"
  [gruvbox]="https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme"
  [osaka]="https://github.com/Fausto-Korpsvart/Osaka-GTK-Theme"
  [tokyonight]="https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme"
  [nightfox]="https://github.com/Fausto-Korpsvart/Nightfox-GTK-Theme"
  [catppuccin]="https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme"
  [juno]="https://github.com/EliverLara/Juno"
)

declare -A THEME_SCHEMES=(
  [everforest]="soft"
  [kanagawa]="dragon"
  [gruvbox]="soft"
  [osaka]="solarized"
  [tokyonight]="moon"
  [nightfox]="nightfox nordfox terafox duskfox carbonfox"
  [catppuccin]="mocha macchiato frappe"
)

THEME_FAMILIES=(everforest kanagawa gruvbox osaka tokyonight nightfox catppuccin juno)

# Map installed theme directory names (best-effort for gsettings)
declare -A THEME_GTK_NAMES=(
  [everforest]="Everforest-Dark"
  [kanagawa]="Kanagawa-Dark"
  [gruvbox]="Gruvbox-Dark"
  [osaka]="Osaka-Dark"
  [tokyonight]="Tokyonight-Dark"
  [nightfox]="Nightfox-Dark"
  [catppuccin]="Catppuccin-Dark"
  [juno]="Juno"
)

install_fausto_theme_family() {
  local family="$1"
  local url="${THEME_REPOS[$family]}"
  local dest
  dest="$(clone_or_update "$url" "${family}-gtk")"

  if [[ "$family" == "juno" ]]; then
    install_juno_theme "$dest"
    return
  fi

  local schemes="${THEME_SCHEMES[$family]}"

  if [[ "$family" == "catppuccin" ]]; then
    install_catppuccin_theme "$dest" "$schemes"
    return
  fi

  ensure_theme_build_deps
  local themes_dir="${dest}/themes"
  if [[ ! -f "${themes_dir}/install.sh" ]]; then
    warn "install.sh not found in ${themes_dir}"
    return 1
  fi
  chmod +x "${themes_dir}/install.sh"

  pushd "$themes_dir" >/dev/null
  export BATCH_MODE=true

  for scheme in $schemes; do
  if [[ "$scheme" == "nightfox" ]]; then
    for color in "${FAUSTO_COLORS[@]}"; do
    log "Installing ${family} color=${color} scheme=default (nightfox)"
    ./install.sh -t "$color" -c dark -s standard -l || warn "Install failed: ${family} ${color} default"
    done
  else
    for color in "${FAUSTO_COLORS[@]}"; do
    log "Installing ${family} color=${color} scheme=${scheme}"
    ./install.sh -t "$color" -c dark -s standard --tweaks "$scheme" -l || warn "Install failed: ${family} ${color} ${scheme}"
    done
  fi
  done

  popd >/dev/null
  ok "Finished theme family: ${family}"
}

install_catppuccin_theme() {
  local dest="$1"
  local schemes="$2"

  local themes_dir="${dest}/themes"
  if [[ ! -f "${themes_dir}/install.sh" ]]; then
    warn "Catppuccin install.sh not found in ${themes_dir}"
    return 1
  fi
  chmod +x "${themes_dir}/install.sh"

  pushd "$themes_dir" >/dev/null
  export BATCH_MODE=true

  local accents=(blue teal sapphire sky)
  for scheme in $schemes; do
  for accent in "${accents[@]}"; do
    if [[ "$scheme" == "mocha" ]]; then
    log "Installing Catppuccin accent=${accent} scheme=Mocha (default)"
    ./install.sh -a "$accent" -m dark -s standard -l || warn "Catppuccin install failed: ${accent} mocha"
    else
    log "Installing Catppuccin accent=${accent} scheme=${scheme}"
    ./install.sh -a "$accent" -m dark -s standard --tweaks "$scheme" -l || warn "Catppuccin install failed: ${accent} ${scheme}"
    fi
  done
  done

  popd >/dev/null
  ok "Finished Catppuccin theme variants"
}

install_juno_theme() {
  local dest="$1"
  local theme_dest="${HOME}/.themes/Juno"
  mkdir -p "${HOME}/.themes"
  if [[ -d "$theme_dest" ]]; then
  rm -rf "$theme_dest"
  fi
  cp -a "$dest" "$theme_dest"
  ok "Installed Juno to ${theme_dest}"
}

install_all_themes() {
  local family
  for family in "${THEME_FAMILIES[@]}"; do
    install_fausto_theme_family "$family" || warn "Theme family failed: ${family}"
  done
}

apply_random_theme() {
  local family
  family="$(rand_pick THEME_FAMILIES)"
  log "Applying random theme family: ${family}"
  install_fausto_theme_family "$family"
  apply_gtk_theme "${THEME_GTK_NAMES[$family]}"
}
