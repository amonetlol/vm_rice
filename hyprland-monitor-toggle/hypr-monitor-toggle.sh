#!/usr/bin/env bash
set -euo pipefail

CONFIG="${HOME}/.config/hypr/hyprland.lua"

notify() {
  if command -v dunstify >/dev/null 2>&1; then
    dunstify "$@"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

if grep -q '^hl\.monitor({ output = "Virtual-1", mode = "1920x1080@60"' "$CONFIG"; then
  sed -i 's/^hl\.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "0x0", scale = 1 })$/--hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "0x0", scale = 1 })/' "$CONFIG"
  sed -i 's/^--hl\.monitor({ output = "Virtual-1", mode = "", position = "0x0", scale = 1 })$/hl.monitor({ output = "Virtual-1", mode = "", position = "0x0", scale = 1 })/' "$CONFIG"
  hyprctl keyword monitor "Virtual-1,preferred,auto,1"
  notify "Monitor Virtual-1" "Modo automático (preferred)"
  hyprctl reload
else
  sed -i 's/^--hl\.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "0x0", scale = 1 })$/hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "0x0", scale = 1 })/' "$CONFIG"
  sed -i 's/^hl\.monitor({ output = "Virtual-1", mode = "", position = "0x0", scale = 1 })$/--hl.monitor({ output = "Virtual-1", mode = "", position = "0x0", scale = 1 })/' "$CONFIG"
  hyprctl keyword monitor "Virtual-1,1920x1080@60,0x0,1"
  notify "Monitor Virtual-1" "Modo fixo 1920x1080@60"
  hyprctl reload
fi
