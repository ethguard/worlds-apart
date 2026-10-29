#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
DIR="$HOME/.local/share/teigu-rice/wallpaper"
mkdir -p "$HOME/Pictures/Wallpapers"
if [[ $# -gt 0 ]]; then
    wallpaper="$1"
    [[ -f "$wallpaper" ]] || { notify-send 'Wallpaper' "File not found: $wallpaper"; exit 1; }
else
    mapfile -d '' -t wallpapers < <(find -L "$DIR" "$HOME/Pictures/Wallpapers" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)
    if ((${#wallpapers[@]} == 0)); then
        notify-send 'Wallpaper' "No images found in $DIR"
        exit 1
    fi
    wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
fi
# Generate all imported theme files before asking consumers to reload.
python3 "$HOME/.config/world80-gallery/theme.py" apply "$wallpaper"
ln -sfn "$wallpaper" "$HOME/.cache/wal/current-wallpaper"
if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    for _ in {1..50}; do
        awww query >/dev/null 2>&1 && break
        sleep 0.1
    done
fi
awww img "$wallpaper" --transition-type center --transition-step 90
if [[ -f "$HOME/.cache/wal/cava" ]]; then
    cp "$HOME/.cache/wal/cava" "$HOME/.config/cava/config"
    pkill -USR1 -x cava || true
fi
cp "$HOME/.cache/wal/wofi.css" "$HOME/.config/wofi/style.css"
pkill -USR1 -x kitty || true
pkill -USR2 -x waybar || true
hyprctl reload >/dev/null
if pgrep -x swaync >/dev/null; then
    swaync-client -R >/dev/null || true
    swaync-client -rs >/dev/null || true
fi
mkdir -p "$HOME/.cache/teigu-rice"
printf '%s\n' "${TEIGU_VIDEO_WALLPAPER:-}" > "$HOME/.cache/teigu-rice/active-video"
notify-send 'Theme updated'  "Colors matched to: $(basename "$wallpaper")" || true
