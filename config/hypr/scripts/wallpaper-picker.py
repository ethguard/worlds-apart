#!/usr/bin/env python3
"""Browse bundled and personal wallpapers with thumbnail previews."""
import fcntl
import hashlib
from pathlib import Path
import subprocess

home = Path.home()
cache = home / '.cache/teigu-rice'
cache.mkdir(parents=True, exist_ok=True)
lock = (cache / 'wallpaper-picker.lock').open('w')
try:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    raise SystemExit(0)
custom = home / 'Pictures/Wallpapers'
custom.mkdir(parents=True, exist_ok=True)
roots = [home / '.local/share/teigu-rice/wallpaper', custom]
thumbs = cache / 'thumbnails'
thumbs.mkdir(exist_ok=True)
entries = {}
current = home / '.cache/wal/current-wallpaper'
current = current.resolve() if current.exists() else None
for root in roots:
    for path in sorted(root.rglob('*')):
        if not path.is_file() or path.suffix.lower() not in {'.png', '.jpg', '.jpeg', '.webp'}:
            continue
        stat = path.stat()
        key = hashlib.sha256(f'{path}:{stat.st_mtime_ns}:{stat.st_size}'.encode()).hexdigest()
        thumbnail = thumbs / f'{key}.png'
        if not thumbnail.exists():
            result = subprocess.run(['magick', str(path) + '[0]', '-auto-orient', '-thumbnail', '220x124^', '-gravity', 'center', '-extent', '220x124', str(thumbnail)], capture_output=True)
            if result.returncode:
                continue
        name = str(path.relative_to(root).with_suffix('')).replace('/', ' / ').replace('-still', '').replace('\n', ' ').replace('\r', ' ')
        label = ('✓ ' if path.resolve() == current else '') + name
        entries[f'img:{thumbnail}:text:{label}'] = path
if not entries:
    subprocess.run(['notify-send', 'Wallpapers', f'Add images to {custom}'])
    raise SystemExit(0)
result = subprocess.run([
    'wofi', '--conf', str(home / '.config/wofi/wallpaper-picker.conf'),
    '--style', str(home / '.config/wofi/wallpaper-picker.css'),
    '--dmenu', '--cache-file', '/dev/null',
], input='\n'.join(entries) + '\n', text=True, capture_output=True)
if result.returncode:
    raise SystemExit(0)
selected = entries.get(result.stdout.rstrip('\n'))
if selected:
    subprocess.run([str(home / '.config/hypr/scripts/change_wallpaper.sh'), str(selected)], check=True)
