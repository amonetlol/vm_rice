#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

declare -A SCRIPTS=(
  [1]="1.temas.sh|Catppuccin GTK themes"
  [2]="2.icones.sh|McMojave-circle icons"
  [3]="3.cursor.sh|Qogir cursor theme"
  [4]="4.gnome-tweaks.sh|GNOME tweaks and keybinds"
  [5]="5.configs.sh|amonetlol dotfiles and configs"
  [6]="6.apps.sh|Desktop apps (herdr, Brave, Blackbox)"
  [7]="7.base_apps.sh|Base packages and CLI tools"
)

show_menu() {
  echo
  log "Debian Sid setup — select scripts to run"
  echo
  local i
  for i in $(seq 1 7); do
  IFS='|' read -r file desc <<< "${SCRIPTS[$i]}"
    printf '  %d) %s — %s\n' "$i" "$file" "$desc"
  done
  echo
  echo "  all) Run 7→6→5→1→2→3→4 (recommended dependency order)"
  echo
}

parse_selection() {
  local input="$1"
  local -a selected=()
  input="${input// /}"

  if [[ "$input" == "all" ]]; then
    # base → apps → configs → rice → gnome tweaks last
    selected=(7 6 5 1 2 3 4)
    printf '%s\n' "${selected[@]}"
    return 0
  fi

  local part
  IFS=',' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      local start="${BASH_REMATCH[1]}" end="${BASH_REMATCH[2]}"
      local n
      for ((n=start; n<=end; n++)); do
        [[ -n "${SCRIPTS[$n]:-}" ]] && selected+=("$n")
      done
    elif [[ "$part" =~ ^[0-9]+$ && -n "${SCRIPTS[$part]:-}" ]]; then
      selected+=("$part")
    else
      die "Invalid selection: $part"
    fi
  done

  if ((${#selected[@]} == 0)); then
    die "No valid scripts selected"
  fi

  printf '%s\n' "${selected[@]}"
}

run_script() {
  local num="$1"
  IFS='|' read -r file desc <<< "${SCRIPTS[$num]}"
  local path="$SCRIPT_DIR/$file"
  [[ -x "$path" || -f "$path" ]] || die "Missing script: $path"
  echo
  log "Running [$num] $file — $desc"
  bash "$path"
  ok "Finished $file"
}

main() {
  show_menu
  read -rp "[*] Enter number, comma list, range (e.g. 2-5), or all: " choice
  [[ -n "$choice" ]] || die "No selection entered"

  mapfile -t nums < <(parse_selection "$choice")
  local n
  for n in "${nums[@]}"; do
    run_script "$n"
  done

  ok "All selected scripts completed"
}

main "$@"