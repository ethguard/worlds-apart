#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.cache/teigu-rice"
# Start the bar before wallpaper setup so a theme error cannot prevent it.
if ! pgrep -x waybar >/dev/null; then
    waybar >"$HOME/.cache/teigu-waybar.log" 2>&1 &
fi
touch "$HOME/.cache/teigu-rice/active-video"
export TEIGU_VIDEO_WALLPAPER="$(cat "$HOME/.cache/teigu-rice/active-video")"
if [[ -f "$HOME/.cache/wal/current-wallpaper" ]]; then
    "$HOME/.config/hypr/scripts/change_wallpaper.sh" "$(readlink -f "$HOME/.cache/wal/current-wallpaper")"
else
    "$HOME/.config/hypr/scripts/change_wallpaper.sh"
fi
quickshell --path "$HOME/.config/world80-gallery" --no-duplicate --daemonize >> "$HOME/.cache/world80-gallery.log" 2>&1
if ! pgrep -x swaync >/dev/null; then
    swaync >"$HOME/.cache/teigu-swaync.log" 2>&1 &
fi
if ! pgrep -f '(^|/)(hyprpolkitagent|polkit-kde-authentication-agent-1)( |$)' >/dev/null; then
    agent=""
    if command -v hyprpolkitagent >/dev/null 2>&1; then
        agent="$(command -v hyprpolkitagent)"
    elif command -v polkit-kde-authentication-agent-1 >/dev/null 2>&1; then
        agent="$(command -v polkit-kde-authentication-agent-1)"
    else
        for candidate in /usr/lib/polkit-kde-authentication-agent-1 /usr/libexec/polkit-kde-authentication-agent-1; do
            if [[ -x "$candidate" ]]; then agent="$candidate"; break; fi
        done
    fi
    if [[ -n "$agent" ]]; then "$agent" >"$HOME/.cache/teigu-polkit.log" 2>&1 & fi
fi
