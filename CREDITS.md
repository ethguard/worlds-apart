# Credits

This rice combines an existing desktop configuration, adapted upstream UI, and custom integration. Credit belongs to the projects and artists below.

## Desktop configuration and adapted features

| Creator / project | Contribution |
| --- | --- |
| [Teiguuu / dotfiles](https://github.com/Teiguuu/dotfiles) | Original rice and repository foundation: Hyprland, Waybar, Wofi, lock/logout screens, editor setup, and bundled assets. Base revision: `4ecf0cd23d6dfb9a2ccfd7065dd1fe35510aa8ac`. |
| [AidanMercer / world80](https://github.com/AidanMercer/world80) | Original Vernissage gallery UI and shared theme tokens, adapted in `config/world80-gallery/ThemeSwitcher.qml` and `Theme.qml`. Source revision: `d89e092ff5958997a1b84b2634dfa64a071314e4`. |
| [AidanMercer / themes](https://github.com/AidanMercer/themes) | Source collection for the optionally downloaded World80 wallpapers and theme metadata. Collection hosting does not identify every original artist. |
| [sarodscommits / hyprland-infinitie-desktop-v2](https://github.com/sarodscommits/hyprland-infinitie-desktop-v2) | Inspiration for the infinite canvas interaction. This rice implements it using native Hyprland Lua rather than shipping the original Python input daemon. |
| [EdenEast / nightfox.nvim](https://github.com/EdenEast/nightfox.nvim) | Bundled Nightfox Lua theme code and lualine themes in `config/nvim/lua/`. MIT notice preserved in `licenses/`. Existing source references to Neovim, lua-bit-numberlua, Catppuccin, and other projects remain in those files. |
| [karlstav / cava](https://github.com/karlstav/cava) | Audio visualizer and bundled example shaders/themes in `config/cava/`. The `eye_of_phi.frag` header additionally credits Shadertoy user ChunderFPV. |
| [fastfetch-cli / fastfetch](https://github.com/fastfetch-cli/fastfetch) | System information display and the Arch ASCII logo exported to `config/images/arch.txt`. |

Custom integration added here includes wallpaper scanning and application, saved color palettes, standalone gallery adapters and video playback integration, the searchable shortcut guide, and the native Lua canvas with zoom and window restoration.

## Wallpapers and artwork

- [MoeWalls](https://moewalls.com/): source site for the user's six personal animated wallpapers (tank forest, Furina midnight meadow, shadow blade monochrome, Firewatch rainy day, early morning forest, and wavy grass). Videos are not distributed here. MoeWalls is the download source; original artists retain credit for their artwork.
- [AidanMercer's themes collection](https://github.com/AidanMercer/themes): optional World80 downloads; local import metadata records the source in `SOURCE.json`.
- The original rice includes 17 still wallpapers and logout icons with incomplete creator/source information. See [THIRD_PARTY.md](THIRD_PARTY.md); their inclusion is not a claim of authorship.
- Screenshot applications include Cava, Fastfetch, Matrix-style terminal output, and a pixel animation. The Matrix and pixel-animation programs are not identified or bundled as part of this release.

## Software powering the desktop

Thanks to the maintainers and contributors of:

- [Hyprland](https://github.com/hyprwm/Hyprland) and [Hyprlock](https://github.com/hyprwm/hyprlock).
- [Quickshell](https://quickshell.org/) and [Qt](https://www.qt.io/), including Qt Multimedia.
- [Waybar](https://github.com/Alexays/Waybar), [Wofi](https://hg.sr.ht/~scoopta/wofi), [SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter), and [wlogout](https://github.com/ArtsyMacaw/wlogout).
- [Kitty](https://github.com/kovidgoyal/kitty) and [Alacritty](https://github.com/alacritty/alacritty).
- [awww](https://codeberg.org/LGFae/awww), [pywal16](https://github.com/eylles/pywal16), and the original [pywal](https://github.com/dylanaraps/pywal).
- [FFmpeg](https://ffmpeg.org/), [ImageMagick](https://imagemagick.org/), [grim](https://sr.ht/~emersion/grim/), [slurp](https://github.com/emersion/slurp), and [wl-clipboard](https://github.com/bugaevc/wl-clipboard).
- [Thunar](https://docs.xfce.org/xfce/thunar/start), [NetworkManager](https://networkmanager.dev/), [Blueman](https://github.com/blueman-project/blueman), and [brightnessctl](https://github.com/Hummer12007/brightnessctl).
- [Neovim](https://neovim.io/) and the [configured plugin authors](docs/neovim-plugins.md).
- [Nerd Fonts](https://www.nerdfonts.com/), [JetBrains Mono](https://www.jetbrains.com/lp/mono/), and [Noto Fonts](https://notofonts.github.io/).
- [Arch Linux](https://archlinux.org/) and [CachyOS](https://cachyos.org/).

Names and project links acknowledge their work; they do not imply endorsement. Dependency software and downloaded artwork retain their own licenses.
