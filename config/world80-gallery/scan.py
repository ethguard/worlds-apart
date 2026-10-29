#!/usr/bin/env python3
"""Adapt personal wallpaper collections to Vernissage's original scan protocol."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
from theme import palette_for

home = Path.home()
base = home / 'Pictures/Wallpapers'
cache = home / '.cache/teigu-rice/video-stills'
cache.mkdir(parents=True, exist_ok=True)
try:
    catalog = json.loads((Path(__file__).parent / 'catalog.json').read_text())
except (OSError, ValueError):
    catalog = {}
current = home / '.cache/wal/current-wallpaper'
print('A\t' + (str(current.resolve()) if current.exists() else ''))
extensions = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.mp4', '.webm', '.avif'}
groups = {}
for root in (home / '.local/share/teigu-rice/wallpaper', base):
    if not root.exists():
        continue
    for p in root.rglob('*'):
        if not p.is_file() or p.suffix.lower() not in extensions or p.stem.endswith('-still'):
            continue
        group = 'Original / ' + p.stem if root != base else ('Personal' if p.parent == base else p.parent.relative_to(base).as_posix())
        groups.setdefault(group, []).append(p)
for name, paths in sorted(groups.items()):
    accents = [c.lstrip('#') for c in catalog.get(name.split('/')[-1], [])]
    print('\t'.join(['T', name, str(paths[0].parent)] + accents))
    for path in sorted(paths, key=lambda p: [int(t) if t.isdigit() else t for t in re.split(r'(\d+)',p.name)]):
        video = path.suffix.lower() in {'.mp4', '.webm'}
        thumb = path
        if video:
            thumb = path.with_name(path.stem + '-still.jpg')
            if not thumb.exists():
                thumb = cache / (hashlib.sha256(str(path).encode()).hexdigest() + '.jpg')
                if not thumb.exists():
                    result = subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-ss', '1', '-i', str(path), '-frames:v', '1', '-q:v', '2', '-update', '1', str(thumb)], capture_output=True)
                    if result.returncode:
                        continue
        palette = palette_for(thumb)
        colors = [palette['colors'][f'color{i}'].lstrip('#') for i in (4, 6, 5)] if palette else accents
        print('\t'.join(['V', str(path), str(thumb), '1' if video else '0'] + colors))
