#!/usr/bin/env python3
"""Apply still/video wallpapers while keeping the current rice's theme hooks."""
import hashlib
import os
from pathlib import Path
import subprocess
import sys

path = Path(sys.argv[1]).resolve(strict=True)
video = path.suffix.lower() in {'.mp4', '.webm'}
image = path
if video:
    image = path.with_name(path.stem + '-still.jpg')
    if not image.exists():
        cache = Path.home() / '.cache/teigu-rice/video-stills'
        cache.mkdir(parents=True, exist_ok=True)
        image = cache / (hashlib.sha256(str(path).encode()).hexdigest() + '.jpg')
        if not image.exists():
            subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-ss', '1', '-i', str(path), '-frames:v', '1', '-q:v', '2', '-update', '1', str(image)], check=True)
env = dict(os.environ, TEIGU_VIDEO_WALLPAPER=str(path) if video else '')
subprocess.run([str(Path.home() / '.config/hypr/scripts/change_wallpaper.sh'), str(image)], env=env, check=True)
