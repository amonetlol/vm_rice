#!/usr/bin/env bash
set -euo pipefail
pkill -x waybar 2>/dev/null || true
sleep 0.15
CFG=$HOME/.config/hypr4/waybar/config.jsonc
CSS=$HOME/.config/hypr4/waybar/style.css
waybar -c $CFG -s $CSS >/dev/null 2>&1 &
hyprctl notify 1 2000 rgb(5adecd) Reloaded Hyprland accessories
