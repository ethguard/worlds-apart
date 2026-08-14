-- ============================================================
--  hyprland.lua — сконвертировано из hyprland.conf (hyprlang)
--  для Hyprland 0.55+, см. https://wiki.hypr.land/Configuring/Start/
-- ============================================================
-- Пока в ~/.config/hypr/ нет файла hyprland.lua, Hyprland продолжает
-- грузить старый hyprland.conf как обычно (выбор делается один раз при
-- старте). Так что можно спокойно положить этот файл рядом и потестить
-- (hyprctl reload), не удаляя старый .conf — если что-то не так, просто
-- временно переименуй/убери hyprland.lua, и старый конфиг снова заработает.

------------------------
---- ЦВЕТА ИЗ PYWAL ----
------------------------
-- В hyprlang было просто: source = ~/.cache/wal/colors-hyprland.conf
-- В lua-конфиге аналог source — это require(), а require() грузит только
-- .lua-модули. colors-hyprland.conf же по-прежнему в старом синтаксисе
-- ($color1 = ...), поэтому require его напрямую не сработает.
--
-- Если твоя версия pywal уже кладёт рядом colors-hyprland.lua — глянь
-- через `hyprctl repl`, что именно возвращает
-- dofile(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.lua"),
-- и используй его вместо функции ниже (набор полей может отличаться
-- в зависимости от версии pywal).
--
-- Вариант ниже не зависит от версии pywal — читает старый .conf-файл
-- руками и парсит строки вида "$colorN = значение":
local function load_wal_colors()
    local colors = {}
    local path = os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf"
    local f = io.open(path, "r")
    if f then
        for line in f:lines() do
            local name, value = line:match("^%$(%S+)%s*=%s*(.-)%s*$")
            if name then
                colors[name] = value
            end
        end
        f:close()
    end
    return colors
end

local wal = load_wal_colors()

------------------
---- МОНИТОРЫ ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1,
})

-----------------------
---- МОИ ПРОГРАММЫ ----
-----------------------
local terminal    = "alacritty"
local fileManager = "thunar"
local cursor      = "hyprctl setcursor clay 24"

-------------------
---- АВТОСТАРТ ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("~/.config/hypr/scripts/change_wallpaper.sh")
    hl.exec_cmd("swaync")
    hl.exec_cmd(cursor)
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)

-------------------------------
---- ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

---------------------
---- ВНЕШНИЙ ВИД ----
---------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 8,
        border_size = 2,

        ["col.active_border"] = {
            colors = {
                wal.color1 or "rgba(ffffffcc)",
                wal.color2 or "rgba(111111cc)",
            },
            angle = 45,
        },

        ["col.inactive_border"] = "rgba(333333aa)",
        layout = "dwindle",
    },
})

------------------
---- АНИМАЦИИ ----
------------------
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("back_out",     { type = "bezier", points = { {0.34, 1.56}, {0.64, 1} } })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })

-- Анимация окон

local animations_enabled = true

hl.animation({
    leaf = "windows",
    enabled = animations_enabled,
    speed = 5,
    bezier = "back_out",
    style = "slide",
})

hl.animation({
    leaf = "windowsIn",
    enabled = animations_enabled,
    speed = 5,
    bezier = "back_out",
    style = "slide",
})

hl.animation({
    leaf = "windowsOut",
    enabled = animations_enabled,
    speed = 5,
    bezier = "easeOutQuint",
    style = "slide",
})

hl.animation({
    leaf = "workspaces",
    enabled = animations_enabled,
    speed = 6,
    bezier = "back_out",
    style = "slide",
})

hl.config({
    dwindle = {
        -- pseudotile = true,
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        animate_manual_resizes = false,
    },
})

--------------
---- ВВОД ----
--------------
hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat", -- помогает CPU меньше считать кривые ускорения
        repeat_delay = 600,
        force_no_accel = true,
        repeat_rate = 25,
    },
})

-------------------------
---- КЛАВИШИ (BINDS) ----
-------------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill wofi || wofi --show drun"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.kill())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Перемещение фокуса
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Переключение воркспейсов + перенос окна на воркспейс (SUPER+SHIFT)
for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Скролл воркспейсов мышкой
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Перетаскивание окон
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Мультимедиа
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })

-- Скриншот и обои
hl.bind("Print",     hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/change_wallpaper.sh"))

-- Уведы
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
