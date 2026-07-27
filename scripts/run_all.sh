#!/usr/bin/env bash
# Non-interactive runner for all vm_rice install scripts
# Usage: run_all.sh [start_index]   (default: 1)
set -euo pipefail

export VM_RICE_SUDO_PASS="${VM_RICE_SUDO_PASS:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
chmod +x *.sh lib/*.sh 2>/dev/null || true

readonly -a SCRIPTS=(
  "1.yay.sh"
  "2.pacman.sh"
  "3.aur.sh"
  "4.temas.sh"
  "5.icones_and_cursor.sh"
  "6.configs_tweaks.sh"
  "7.binds_gnome.sh"
  "8.logout_fix.sh"
)

start_idx="${1:-1}"
(( start_idx >= 1 && start_idx <= 8 )) || { echo "Invalid start index: ${start_idx}" >&2; exit 1; }

for ((i = start_idx - 1; i < ${#SCRIPTS[@]}; i++)); do
  s="${SCRIPTS[$i]}"
  echo "===== START ${s} ====="
  bash "$s"
  echo "===== SUCCESS ${s} ====="
done

echo "===== ALL SCRIPTS COMPLETE ====="
