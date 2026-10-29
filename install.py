#!/usr/bin/env python3
"""Install this rice with backups; run as your normal desktop user."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

parser = argparse.ArgumentParser(description='Install desktop configuration with a restorable backup.')
parser.add_argument('--check', action='store_true', help='report prerequisites without changing files')
args = parser.parse_args()
repo = Path(__file__).resolve().parent
home = Path.home()
if os.geteuid() == 0:
    sys.exit('Run as your regular desktop user, not root.')
if not sys.platform.startswith('linux'):
    sys.exit('This Hyprland configuration requires Linux.')
os.environ['PATH'] = str(home / '.local/bin') + ':' + os.environ['PATH']
required = ['Hyprland', 'hyprctl', 'waybar', 'wofi', 'swaync', 'kitty',
            'awww', 'awww-daemon', 'wal', 'hyprlock', 'thunar', 'wlogout',
            'quickshell', 'ffmpeg', 'grim', 'slurp', 'wl-copy', 'notify-send']
missing = [cmd for cmd in required if not shutil.which(cmd)]
if missing:
    sys.exit('Missing programs: ' + ', '.join(missing) +
             '\nInstall them using your distribution packages, then run python3 install.py --check. See INSTALL.md.')
try:
    version = subprocess.check_output(['hyprctl', 'version'], text=True, stderr=subprocess.DEVNULL)
except (subprocess.CalledProcessError, OSError):
    sys.exit('Start a Hyprland session first; this installer reads its active display and keyboard settings.')
import re
match = re.search(r'(?:Hyprland )?(\d+)\.(\d+)\.(\d+)', version)
if match and (int(match.group(1)), int(match.group(2))) < (0, 55):
    sys.exit('Hyprland 0.55 or newer with Lua configuration is required.')
try:
    monitors = json.loads(subprocess.check_output(['hyprctl', 'monitors', '-j']))
    layout = json.loads(subprocess.check_output(['hyprctl', '-j', 'getoption', 'input:kb_layout']))['str']
    options = json.loads(subprocess.check_output(['hyprctl', '-j', 'getoption', 'input:kb_options']))['str']
except (subprocess.CalledProcessError, ValueError, KeyError) as exc:
    sys.exit(f'Could not read live Hyprland settings: {exc}')
if not monitors:
    sys.exit('No active display was reported by Hyprland.')
subprocess.run(['Hyprland', '--verify-config', '-c', str(repo / 'config/hypr/hyprland.lua')], check=True)
if args.check:
    print('Prerequisites available. Active displays:', ', '.join(m['name'] for m in monitors))
    print('No files changed. Run ./install.sh to install.')
    sys.exit(0)
backup = home / '.local/state/teigu-rice/backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
backup.mkdir(parents=True)
manifest = []

def save(target):
    relative = target.relative_to(home)
    old = backup / 'original' / relative
    existed = target.exists() or target.is_symlink()
    manifest.append({'path': str(relative), 'existed': existed})
    (backup / 'manifest.json').write_text(json.dumps(manifest, indent=2))
    if existed:
        old.parent.mkdir(parents=True, exist_ok=True)
        target.rename(old)
    target.parent.mkdir(parents=True, exist_ok=True)

restore = backup / 'restore.py'
restore.write_text('''#!/usr/bin/env python3
import json
from pathlib import Path
import subprocess
backup = Path(__file__).resolve().parent
home = Path.home()
for entry in reversed(json.loads((backup / 'manifest.json').read_text())):
    target = home / entry['path']
    displaced = backup / 'replaced' / entry['path']
    if target.exists() or target.is_symlink():
        displaced.parent.mkdir(parents=True, exist_ok=True)
        target.rename(displaced)
    if entry['existed']:
        (backup / 'original' / entry['path']).rename(target)
subprocess.run(['hyprctl', 'reload'])
print('Original configuration restored. Log out and back in to restore session services.')
''')

# Preserve the old symlink itself, leaving its dotfiles repository untouched.
for source in sorted((repo / 'config').iterdir()):
    target = home / '.config' / source.name
    save(target)
    shutil.copytree(source, target)
cache = home / '.cache/wal'
save(cache)
cache.mkdir(parents=True)
assets = home / '.local/share/teigu-rice/wallpaper'
save(assets)
shutil.copytree(repo / 'wallpaper', assets)
for folder in ('waybar', 'swaync', 'wlogout'):
    (home / '.config' / folder / 'colors-waybar.css').symlink_to(cache / 'colors-waybar.css')
for script in (home / '.config/hypr/scripts').glob('*.sh'):
    script.chmod(0o755)
local = ['-- Retain the displays and keyboard layout active at installation.']
for monitor in monitors:
    local.append('hl.monitor({ output = %s, mode = %s, position = %s, scale = %s })' % (
        json.dumps(monitor['name']),
        json.dumps(f"{monitor['width']}x{monitor['height']}@{monitor['refreshRate']:.2f}"),
        json.dumps(f"{monitor['x']}x{monitor['y']}"), monitor['scale']))
local.append('hl.config({ input = { kb_layout = %s, kb_options = %s } })' % (json.dumps(layout), json.dumps(options)))
(home / '.config/hypr/local.lua').write_text('\n'.join(local) + '\n')
bar = home / '.config/waybar/config'
data = json.loads(bar.read_text())
if not shutil.which('ideapad-cm'):
    data['group/system-info']['modules'].remove('custom/battery_limit')
    del data['custom/battery_limit']
if not list(Path('/sys/class/power_supply').glob('BAT*')):
    data['group/system-info']['modules'].remove('battery')
if not list(Path('/sys/class/backlight').glob('*')):
    for name in ('custom/backlight_down', 'custom/backlight_up'):
        data['modules-left'].remove(name)
sensors = sorted(Path('/sys/class/hwmon').glob('hwmon*/temp1_input'))
cpu_sensor = next((p for p in sensors if (p.parent / 'name').exists() and (p.parent / 'name').read_text().strip() in ('k10temp', 'coretemp')), None)
if cpu_sensor:
    data['temperature']['hwmon-path'] = str(cpu_sensor)
elif not Path('/sys/class/thermal/thermal_zone0/temp').exists():
    data['modules-right'].remove('temperature')
if not list(Path('/sys/class/bluetooth').glob('hci*')):
    data['group/system-info']['modules'].remove('bluetooth')
bar.write_text(json.dumps(data, indent=4) + '\n')
# Generate imports before activating the compositor config.
subprocess.run(['wal', '-i', str(assets / 'wallpaper.png'), '-q', '-n', '-s', '-t', '-e'], check=True)
(cache / 'current-wallpaper').symlink_to(assets / 'wallpaper.png')
shutil.copy2(cache / 'wofi.css', home / '.config/wofi/style.css')
subprocess.run(['Hyprland', '--verify-config', '-c', str(home / '.config/hypr/hyprland.lua')], check=True)
print(f'Installed. Backup: {backup}')
print(f'Restore: python3 {restore}')
print('Activate: hyprctl reload; ~/.config/hypr/scripts/start-rice.sh')
