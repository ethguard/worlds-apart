# Install Worlds Apart

The Python installer works without a distribution-specific package manager. It copies the rice into your home directory, preserves your active Hyprland monitor and keyboard settings, adapts Waybar hardware modules, and creates a restorable backup. Run it as your regular user **inside an existing Hyprland session**. Hyprland 0.55 or newer with Lua configuration is required; development and visual checks were on 0.57.0.

1. Install dependencies using your distribution's package manager. The required programs are `Hyprland`, `hyprctl`, `waybar`, `wofi`, `swaync`, `kitty`, `awww`, `awww-daemon`, `wal` (pywal16), `hyprlock`, `thunar`, `wlogout`, `quickshell`, `ffmpeg`, `grim`, `slurp`, `wl-copy`, and `notify-send`. Install a polkit agent such as `hyprpolkitagent` for graphical authorization. Cava, Fastfetch, Alacritty, Neovim, network and Bluetooth applets, and the JetBrains Mono Nerd Font provide the remaining optional features.
2. Run the preflight, then install:

   ```sh
   ./install.sh --check
   ./install.sh
   hyprctl reload
   ~/.config/hypr/scripts/start-rice.sh
   ```

The shell entry point installs Python 3 with a detected package manager if it is missing. On NixOS it uses a user Nix profile. `--check` only reports that Python is missing and leaves the system unchanged. Python 3 is also required at runtime for wallpaper theming and the gallery. The preflight reports missing commands and confirms that the active Hyprland session can be read. It makes no file changes. The installer prints a backup path and the exact restore command. Existing entries, including symlinks, are moved into the backup before the new config is copied. The generated `~/.config/hypr/local.lua` stores the display and keyboard values active at installation.

On **NixOS**, follow [the NixOS guide](docs/NIXOS.md) to enable Hyprland and declare packages before running these commands. On other distributions, package names may differ; use `--check` to confirm the required binaries rather than relying on an Arch package list.

The wallpaper gallery opens with **Super+Shift+T**, the infinite canvas toggles with **Super+Shift+3**, and the full shortcut guide opens with **Super+/**. New wallpapers placed under `~/Pictures/Wallpapers` appear in the gallery. The World80 GitHub collection and the six personal MoeWalls videos are separate optional downloads; their sources are listed in [wallpaper-sources.json](docs/wallpaper-sources.json).

The installer currently installs the bundled still images. The discussed wallpaper chooser (pick previews, get all, or get World80 plus the six videos) is not yet implemented. This installer has not been run on a fresh machine for every distribution.
