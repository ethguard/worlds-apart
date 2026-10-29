#!/usr/bin/env python3
"""Describe the live desktop bindings, plus this rice's contextual controls."""
import json
import subprocess

rows = []
seen = set()

def add(section, keys, action):
    if (keys, action) not in seen:
        seen.add((keys, action))
        rows.append(dict(section=section, keys=keys, action=action))

fixed = {
    (72, 'mouse_up'): ('Infinite desktop', 'Super + Alt + Wheel up', 'Zoom in: enlarge canvas windows'),
    (72, 'mouse_down'): ('Infinite desktop', 'Super + Alt + Wheel down', 'Zoom out: make canvas windows smaller'),
    (72, '0'): ('Infinite desktop', 'Super + Alt + 0', 'Reset the canvas zoom to its starting size'),
    (64, 'Super_L'): ('Applications', 'Tap Super', 'Open / close the app launcher'),
    (64, 'Super_R'): ('Applications', 'Tap Super', 'Open / close the app launcher'),
    (64, 'Q'): ('Applications', 'Super + Q', 'Open Kitty terminal'),
    (64, 'E'): ('Applications', 'Super + E', 'Open Thunar file manager'),
    (64, 'C'): ('Windows', 'Super + C', 'Close the focused window'),
    (64, 'V'): ('Windows', 'Super + V', 'Toggle floating for the focused window'),
    (64, 'P'): ('Windows', 'Super + P', 'Toggle pseudotiling (keep a preferred window size)'),
    (64, 'J'): ('Windows', 'Super + J', 'Toggle horizontal / vertical tiling split'),
    (65, 'F'): ('Windows', 'Super + Shift + F', 'Toggle focused window fullscreen'),
    (64, 'M'): ('Session', 'Super + M', 'Exit Hyprland / log out immediately'),
    (64, 'L'): ('Session', 'Super + L', 'Lock the screen'),
    (64, 'N'): ('Desktop', 'Super + N', 'Open / close the notification center'),
    (64, 'W'): ('Wallpaper & screenshots', 'Super + W', 'Apply a random wallpaper and its matching color theme'),
    (65, 'T'): ('Wallpaper & screenshots', 'Super + Shift + T', 'Open / close the Vernissage wallpaper gallery'),
    (65, 'S'): ('Wallpaper & screenshots', 'Super + Shift + S', 'Select a screenshot area; save and copy to clipboard'),
    (0, 'Print'): ('Wallpaper & screenshots', 'Print Screen', 'Select a screenshot area; save and copy to clipboard'),
    (64, 'slash'): ('Desktop', 'Super + /', 'Open / close this shortcut guide'),
    (64, 'mouse_down'): ('Workspaces', 'Super + Wheel down', 'Switch to the next existing workspace'),
    (64, 'mouse_up'): ('Workspaces', 'Super + Wheel up', 'Switch to the previous existing workspace'),
    (64, 'mouse:272'): ('Windows', 'Super + Left drag', 'Move the focused window with the mouse'),
    (64, 'mouse:273'): ('Windows', 'Super + Right drag', 'Resize the focused window with the mouse'),
    (0, 'XF86AudioRaiseVolume'): ('Audio', 'Volume up', 'Raise volume by 5% (maximum 100%)'),
    (0, 'XF86AudioLowerVolume'): ('Audio', 'Volume down', 'Lower volume by 5%'),
    (0, 'XF86AudioMute'): ('Audio', 'Mute', 'Mute / unmute the default audio output'),
    (65, '3'): ('Infinite desktop', 'Super + Shift + 3', 'Toggle the canvas on this workspace / restore normal tiling'),
    (69, '3'): ('Workspaces', 'Super + Ctrl + Shift + 3', 'Move the focused window to workspace 3'),
}
binds = json.loads(subprocess.check_output(['hyprctl', 'binds', '-j']))
for bind in binds:
    mod, key = bind['modmask'], bind['key']
    if (mod, key) in fixed:
        add(*fixed[(mod, key)])
    elif key.isdigit() and len(key) == 1 and mod in (64, 65):
        number = 10 if key == '0' else int(key)
        add('Workspaces', 'Super + ' + ('Shift + ' if mod == 65 else '') + key,
            ('Move the focused window to' if mod == 65 else 'Switch to') + f' workspace {number}')
    elif key.lower() in ('left', 'right', 'up', 'down') and mod in (64, 65, 68, 72):
        direction = key.lower()
        modifier = {64: '', 65: 'Shift + ', 68: 'Ctrl + ', 72: 'Alt + '}[mod]
        action = {
            64: f'Focus {direction}; in canvas mode, center the neighboring window',
            65: f'Move window {direction}; in canvas mode, move by 90 pixels',
            68: f'Resize the canvas window {direction} by 60 pixels (canvas mode)',
            72: f'Pan the canvas {direction} (canvas mode)',
        }[mod]
        add('Infinite desktop' if mod != 64 else 'Windows', 'Super + ' + modifier + direction.capitalize(), action)
    else:
        mods = [label for bit, label in ((64,'Super'),(4,'Ctrl'),(8,'Alt'),(1,'Shift')) if mod & bit]
        shortcut = ' + '.join(mods + [key or f"Keycode {bind['keycode']}"])
        add('Other shortcuts', shortcut, bind.get('description') or 'Custom binding: ' + bind['dispatcher'])

if any(b['description'] == 'Toggle infinite desktop' for b in binds):
    add('Infinite desktop', 'Hold Super + Alt + move mouse', 'Pan every canvas window together; release to stop')
for keys, action in [
    ('Left / Right', 'Browse wallpaper collections'),
    ('Up / Down', 'Choose a wallpaper variant in the current collection'),
    ('Enter', 'Apply the selected wallpaper and matching theme'),
    ('Escape', 'Close the gallery'),
    ('Mouse wheel', 'Browse collections; over the selected card, browse variants'),
    ('Click a card', 'Focus a card; click the focused card again to apply'),
]: add('Inside the wallpaper gallery', keys, action)
for keys, action in [('L','Lock'),('R','Reboot'),('S','Shut down'),('E','Log out'),('U','Suspend'),('H','Hibernate')]:
    add('Inside the power menu', keys, action + ' (open the menu using the Waybar power icon)')
add('Inside Neovim', 'Space, then E', 'Toggle the file tree in normal mode')
add('Inside this guide', 'Type to search', 'Filter shortcuts by key, action, or section')
add('Inside this guide', 'Escape / Super + /', 'Close the shortcut guide')
order = ['Applications','Windows','Workspaces','Desktop','Wallpaper & screenshots','Infinite desktop','Audio','Session','Inside the wallpaper gallery','Inside the power menu','Inside Neovim','Inside this guide','Other shortcuts']
rows.sort(key=lambda row: (order.index(row['section']) if row['section'] in order else 99, row['keys']))
print(json.dumps(rows))
