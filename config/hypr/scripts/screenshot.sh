#!/usr/bin/env bash
set -euo pipefail
region=$(slurp) || exit 0
[[ -n "$region" ]] || exit 0
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
name="$dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
grim -g "$region" "$name"
wl-copy < "$name"
notify-send 'Screenshot saved' "$name"
