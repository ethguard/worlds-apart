#!/usr/bin/env bash
set -euo pipefail
config="$HOME/.config/world80-gallery"
if quickshell ipc --path "$config" call shortcutGuide toggle >/dev/null 2>&1; then
    exit 0
fi
quickshell --path "$config" --no-duplicate --daemonize >> "$HOME/.cache/world80-gallery.log" 2>&1
for _ in {1..50}; do
    if quickshell ipc --path "$config" call shortcutGuide toggle >/dev/null 2>&1; then
        exit 0
    fi
    sleep 0.1
done
notify-send 'Shortcut guide could not start' 'See ~/.cache/world80-gallery.log'
exit 1
