#!/usr/bin/env bash
set -euo pipefail
HOME_DIR=${HOME}
WALL=$HOME_DIR/.config/hypr4/wallpapers/wallpaper.jpg
if command -v awww-daemon >/dev/null 2>&1; then
 pgrep -x awww-daemon >/dev/null || awww-daemon &
 sleep 0.3
 if [ -f $WALL ]; then
 awww img $WALL
 fi
fi
