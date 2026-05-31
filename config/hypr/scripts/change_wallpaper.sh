#!/bin/bash

DIR="$HOME/Pictures/oboi/Обои"
INDEX_FILE="/tmp/wallpaper_index"

[ ! -f "$INDEX_FILE" ] && echo 0 > "$INDEX_FILE"

# 1. Сбор всех картинок в массив
mapfile -t WALLPAPERS < <(find "$DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) )

# 2. Рандомный выбор из массива
RANDOM_INDEX=$(( RANDOM % ${#WALLPAPERS[@]} ))
WALLPAPER="${WALLPAPERS[$RANDOM_INDEX]}"

# 3. Генерируем палитру
wal -i "$WALLPAPER" -q

awww img "$WALLPAPER" --transition-type center --transition-step 90

# CAVA
if [ -f "$HOME/.cache/wal/cava" ]; then
    cp "$HOME/.cache/wal/cava" "$HOME/.config/cava/config"
    pkill -USR1 cava || true
fi

# WOFI, HYPRLOCK, KITTY
cp ~/.cache/wal/wofi.css ~/.config/wofi/style.css
cp ~/.cache/wal/colors-hyprlock.conf ~/.config/hypr/colors-hyprlock.conf
killall -USR1 kitty 2>/dev/null

# WAYBAR (плавное обновление через сигнал)
pkill -SIGUSR2 waybar

# 4. ТРИГГЕР ДЛЯ ОБНОВЛЕНИЯ РАМОК HYPRLAND
touch ~/.config/hypr/hyprland.conf

# Подготовка следующего индекса
NEXT_INDEX=$(( (INDEX + 1) % ${#WALLPAPERS[@]} ))
echo "$NEXT_INDEX" > "$INDEX_FILE"

# TTY sequences
for term in /dev/pts/[0-9]*; do
    cat ~/.cache/wal/sequences > "$term" 2>/dev/null
done

notify-send "Theme Updated" "Colors matched to: $(basename "$WALLPAPER")"
