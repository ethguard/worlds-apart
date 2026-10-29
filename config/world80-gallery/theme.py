#!/usr/bin/env python3
"""Build and apply a persistent, wallpaper-specific palette without changing the desktop during generation."""
from concurrent.futures import ThreadPoolExecutor, as_completed
import colorsys
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

HOME = Path.home()
STORE = HOME / '.local/share/teigu-rice/themes'
WAL = HOME / '.local/bin/wal'
VERSION = 'wallpaper-theme-v2'


def theme_path(image):
    image = Path(image).resolve(strict=True)
    stat = image.stat()
    identity = f'{VERSION}:{image}:{stat.st_size}:{stat.st_mtime_ns}'
    return STORE / hashlib.sha256(identity.encode()).hexdigest()[:24]


def palette_for(image):
    try:
        return json.loads((theme_path(image) / 'colors.json').read_text())
    except (OSError, ValueError):
        return None


def luminance(color):
    rgb = [int(color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in rgb]
    return sum(a * b for a, b in zip(linear, (.2126, .7152, .0722)))


def contrast(a, b):
    a, b = sorted((luminance(a), luminance(b)))
    return (b + .05) / (a + .05)


def readable(color, background, minimum):
    rgb = [int(color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    hue, lightness, saturation = colorsys.rgb_to_hls(*rgb)
    # Lift lightness against the dark theme while retaining the wallpaper's hue.
    while contrast(color, background) < minimum and lightness < 1:
        lightness = min(1, lightness + .01)
        rgb = colorsys.hls_to_rgb(hue, lightness, saturation)
        color = '#' + ''.join(f'{round(v * 255):02x}' for v in rgb)
    return color


def build(image):
    image = Path(image).resolve(strict=True)
    target = theme_path(image)
    target.mkdir(parents=True, exist_ok=True)
    if not (target / 'source.json').is_file():
        # PYWAL_CACHE_DIR isolates backend caches and terminal sequences as well as exports.
        env = dict(os.environ, PYWAL_CACHE_DIR=str(target), NO_FUN='1')
        subprocess.run([str(WAL), '-i', str(image), '-q', '-n', '-s', '-t', '-e', '--out-dir', str(target)], env=env, check=True)
        palette = json.loads((target / 'colors.json').read_text())
        background = palette['special']['background']
        for i in list(range(1, 7)) + list(range(9, 15)):
            palette['colors'][f'color{i}'] = readable(palette['colors'][f'color{i}'], background, 4.5)
        foreground = readable(palette['special']['foreground'], background, 7)
        palette['special']['foreground'] = foreground
        palette['special']['cursor'] = palette['colors']['color4']
        palette['colors']['color7'] = palette['colors']['color15'] = foreground
        (target / 'palette.json').write_text(json.dumps(palette, indent=2))
        subprocess.run([str(WAL), '--theme', str(target / 'palette.json'), '-q', '-n', '-s', '-t', '-e', '--out-dir', str(target)], env=env, check=True)
        (target / 'source.json').write_text(json.dumps({'image': str(image), 'version': VERSION}, indent=2))
    return target


def apply(image):
    target = build(image)
    # Render from the saved palette, including any newly installed application templates.
    env = dict(os.environ, NO_FUN='1')
    env.pop('PYWAL_CACHE_DIR', None)
    subprocess.run([str(WAL), '--theme', str(target / 'colors.json'), '-i', str(Path(image).resolve()), '-q', '-n', '-s', '-t', '-e'], env=env, check=True)


def build_all():
    scanner = Path(__file__).with_name('scan.py')
    output = subprocess.check_output([sys.executable, str(scanner)], text=True)
    entries = []
    name = ''
    for line in output.splitlines():
        parts = line.split('\t')
        if parts[0] == 'T':
            name = parts[1]
        elif parts[0] == 'V':
            entries.append({'collection': name, 'wallpaper': parts[1], 'image': parts[2], 'video': parts[3] == '1'})
    images = list(dict.fromkeys(entry['image'] for entry in entries))
    with ThreadPoolExecutor(max_workers=3) as pool:
        futures = {pool.submit(build, image): image for image in images}
        for i, future in enumerate(as_completed(futures), 1):
            target = future.result()
            print(f'[{i}/{len(images)}] {futures[future]}', flush=True)
    for entry in entries:
        target = theme_path(entry['image'])
        palette = json.loads((target / 'colors.json').read_text())
        entry['theme'] = str(target)
        entry['accents'] = [palette['colors'][f'color{i}'] for i in (4, 6, 5)]
    STORE.mkdir(parents=True, exist_ok=True)
    (STORE / 'index.json').write_text(json.dumps(entries, indent=2))
    print(f'Built themes for all {len(entries)} wallpapers.', flush=True)


if __name__ == '__main__':
    if sys.argv[1:] == ['build-all']:
        build_all()
    elif len(sys.argv) == 3 and sys.argv[1] == 'apply':
        apply(sys.argv[2])
    else:
        raise SystemExit('Usage: theme.py build-all | theme.py apply IMAGE')
