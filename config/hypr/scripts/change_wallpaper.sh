#!/bin/bash

DIR="$HOME/Pictures/oboi/Обои"

# 1. Сбор всех картинок в массив
mapfile -t WALLPAPERS < <(find "$DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) )

# Проверка, что директория не пустая
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Ошибка" "Обои не найдены в $DIR"
    exit 1
fi

# 2. Рандомный выбор из массива
RANDOM_INDEX=$(( RANDOM % ${#WALLPAPERS[@]} ))
WALLPAPER="${WALLPAPERS[$RANDOM_INDEX]}"

# 3. Генерируем палитру
wal -i "$WALLPAPER" -q

# Смена обоев
awww img "$WALLPAPER" --transition-type center --transition-step 90

# CAVA
if [ -f "$HOME/.cache/wal/cava" ]; then
    cp "$HOME/.cache/wal/cava" "$HOME/.config/cava/config"
    pkill -USR1 cava || true
fi

# HYPRLOCK, KITTY
cp ~/.cache/wal/colors-hyprlock.conf ~/.config/hypr/colors-hyprlock.conf
killall -USR1 kitty 2>/dev/null

# WAYBAR (плавное обновление через сигнал)
pkill -SIGUSR2 waybar

# 4. ТРИГГЕР ДЛЯ ОБНОВЛЕНИЯ РАМОК HYPRLAND
touch ~/.config/hypr/hyprland.conf

# TTY sequences
for term in /dev/pts/[0-9]*; do
    cat ~/.cache/wal/sequences > "$term" 2>/dev/null
done

# Обновление темы Wofi при смене обоев (Безопасный CSS без деформации окна)
source "$HOME/.cache/wal/colors.sh"
cat << EOF > "$HOME/.config/wofi/style.css"
* {
    font-family: "JetBrainsMono NF", monospace;
    font-size: 14px;
}
#window {
    background-color: transparent;
    border: none;
}
#outer-box {
    padding: 10px;
    background-color: ${background};
    color: ${foreground};
    border: 2px solid ${color1};
    border-radius: 0px;
}
#scroll {
    margin: 0px;
    padding: 0px;
    border: none;
}
#input {
    background-color: ${background};
    color: ${foreground};
    border: 2px solid ${color1};
    border-radius: 0px;
    padding: 8px;
    margin-bottom: 10px;
}
#entry {
    padding: 8px;
    border-radius: 0px;
}
#entry:selected {
    background-color: ${color1};
}
#entry:selected text {
    color: ${background};
}
scrollbar, scrollbar button, scrollbar trough, scrollbar slider {
    background-color: transparent;
    background-image: none;
    border: none;
    box-shadow: none;
    min-width: 0px;
    min-height: 0px;
    opacity: 0;
}
EOF

# 5. УВЕДОМЛЕНИЯ И СБРОС КЕША SWAYNC
notify-send "Theme Updated" "Colors matched to: $(basename "$WALLPAPER")"

sleep 0.5
swaync-client -R
swaync-client -rs
