#!/usr/bin/env bash
# vm_rice — Arch Linux GNOME rice installer (main menu)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/themes.sh
source "${SCRIPT_DIR}/lib/themes.sh"
# shellcheck source=lib/icons.sh
source "${SCRIPT_DIR}/lib/icons.sh"

readonly -a SCRIPT_FILES=(
  "1.yay.sh"
  "2.pacman.sh"
  "3.aur.sh"
  "4.temas.sh"
  "5.icones_and_cursor.sh"
  "6.configs_tweaks.sh"
  "7.binds_gnome.sh"
  "8.logout_fix.sh"
)

banner() {
  printf '\n%s%s══════════════════════════════════════════%s\n' "$CYAN" "$BOLD" "$RESET"
  printf '%s%s  vm_rice — Arch Linux GNOME Setup%s\n' "$CYAN" "$BOLD" "$RESET"
  printf '%s%s══════════════════════════════════════════%s\n\n' "$CYAN" "$BOLD" "$RESET"
}

run_script() {
  local num="$1"
  local script="${SCRIPT_DIR}/${num}"
  [[ -f "$script" ]] || die "Script not found: ${script}"
  chmod +x "$script"
  log "Running ${num}..."
  bash "$script"
  ok "Completed ${num}"
}

run_script_by_index() {
  local idx="$1"
  (( idx >= 1 && idx <= 8 )) || die "Script inválido: ${idx}"
  run_script "${SCRIPT_FILES[$((idx - 1))]}"
}

run_all() {
  local i
  for i in $(seq 1 8); do
    run_script_by_index "$i"
  done
}

menu_aleatorio() {
  log "Modo aleatório: tema + ícones aleatórios"
  apply_random_theme
  apply_random_icon
  ok "Aleatório aplicado. Ajuste manualmente em GNOME Tweaks se necessário."
}

menu_aleatorio_range() {
  printf '\n%sFamílias de tema:%s\n' "$BOLD" "$RESET"
  local i=1 fam
  for fam in "${THEME_FAMILIES[@]}"; do
    printf '  %2d) %s\n' "$i" "$fam"
    ((i++)) || true
  done
  printf '\n%sCombos de ícones (exemplos):%s\n' "$BOLD" "$RESET"
  local j=1 combo
  for combo in "${ICON_COMBOS[@]}"; do
    printf '  %2d) %s\n' "$j" "$combo"
    ((j++)) || true
  done

  printf '\nEscolha família de tema (número ou nome, vazio=aleatório): '
  read -r theme_pick
  printf 'Escolha combo de ícones (número ou nome, vazio=aleatório): '
  read -r icon_pick

  if [[ -z "$theme_pick" ]]; then
    apply_random_theme
  else
    local picked_family=""
    if [[ "$theme_pick" =~ ^[0-9]+$ ]]; then
      picked_family="${THEME_FAMILIES[$((theme_pick - 1))]:-}"
    else
      picked_family="$theme_pick"
    fi
    [[ -n "$picked_family" && -n "${THEME_REPOS[$picked_family]:-}" ]] || die "Família inválida: ${theme_pick}"
    install_fausto_theme_family "$picked_family"
    apply_gtk_theme "${THEME_GTK_NAMES[$picked_family]}"
  fi

  if [[ -z "$icon_pick" ]]; then
    apply_random_icon
  else
    local picked_combo=""
    if [[ "$icon_pick" =~ ^[0-9]+$ ]]; then
      picked_combo="${ICON_COMBOS[$((icon_pick - 1))]:-}"
    else
      picked_combo="$icon_pick"
    fi
    [[ -n "$picked_combo" && -n "${ICON_VARIANTS[$picked_combo]:-}" ]] || die "Combo inválido: ${icon_pick}"
    apply_icon_combo "$picked_combo"
  fi
}

show_menu() {
  printf '%sMenu:%s\n' "$BOLD" "$RESET"
  printf '  %s1)%s yay — instalar yay-bin (AUR helper)\n' "$GREEN" "$RESET"
  printf '  %s2)%s pacman — pacotes oficiais\n' "$GREEN" "$RESET"
  printf '  %s3)%s aur — pacotes AUR\n' "$GREEN" "$RESET"
  printf '  %s4)%s temas — temas GTK\n' "$GREEN" "$RESET"
  printf '  %s5)%s ícones e cursor — ícones e cursores\n' "$GREEN" "$RESET"
  printf '  %s6)%s configs e tweaks — configs, extensões, debloat, snapper\n' "$GREEN" "$RESET"
  printf '  %s7)%s binds GNOME — atalhos de teclado\n' "$GREEN" "$RESET"
  printf '  %s8)%s logout fix — sempre mostrar logout\n' "$GREEN" "$RESET"
  printf '  %s0)%s Sair\n' "$RED" "$RESET"
  printf '\nEx: 1,2-5,all\n'
}

validate_script_index() {
  local idx="$1"
  [[ "$idx" =~ ^[0-9]+$ ]] || die "Entrada inválida: ${idx}"
  (( idx >= 1 && idx <= 8 )) || die "Script fora do intervalo (1-8): ${idx}"
}

append_unique_index() {
  local idx="$1"
  local existing
  for existing in "${PARSED_SELECTION[@]}"; do
    [[ "$existing" == "$idx" ]] && return 0
  done
  PARSED_SELECTION+=("$idx")
}

parse_range_part() {
  local part="$1"
  local start end idx

  if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    start="${BASH_REMATCH[1]}"
    end="${BASH_REMATCH[2]}"
    validate_script_index "$start"
    validate_script_index "$end"
    (( start <= end )) || die "Intervalo inválido: ${part}"
    for ((idx = start; idx <= end; idx++)); do
      append_unique_index "$idx"
    done
    return 0
  fi

  if [[ "$part" =~ ^[0-9]+$ ]]; then
    validate_script_index "$part"
    append_unique_index "$part"
    return 0
  fi

  die "Entrada inválida: ${part}"
}

# Populates PARSED_SELECTION with script indices in execution order.
# Returns: 0 = run scripts, 1 = invalid (die already called), 2 = quit, 3 = random
parse_selection() {
  local input="${1// /}"
  local -a parts=()
  local part

  PARSED_SELECTION=()

  if [[ -z "$input" || "$input" == "0" ]]; then
    return 2
  fi

  case "${input,,}" in
    all)
      PARSED_SELECTION=(1 2 3 4 5 6 7 8)
      return 0
      ;;
    random)
      return 3
      ;;
    random-range)
      return 4
      ;;
  esac

  IFS=',' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    [[ -n "$part" ]] || continue
    parse_range_part "$part"
  done

  ((${#PARSED_SELECTION[@]} > 0)) || die "Nenhum script selecionado."
  return 0
}

run_selection() {
  local idx
  for idx in "${PARSED_SELECTION[@]}"; do
    run_script_by_index "$idx"
  done
}

main_menu() {
  local input rc

  while true; do
    banner
    show_menu
    read -r -p "Digite a opção escolhida: " input || input=""

    parse_selection "$input"
    rc=$?

    case "$rc" in
      2)
        ok "Até logo!"
        exit 0
        ;;
      3)
        menu_aleatorio
        ;;
      4)
        menu_aleatorio_range
        ;;
      0)
        run_selection
        ;;
      *)
        die "Falha ao interpretar seleção."
        ;;
    esac

    printf '\nPressione Enter para continuar...'
    read -r _ || true
  done
}

require_arch
main_menu
