# NixOS guide

This configuration uses Hyprland's Lua API. Use a NixOS release or Hyprland package with **0.55 or newer**; the configuration was developed on 0.57.0. The NixOS module handles the session and desktop portal. The repository installer copies user configuration and generates a backup; it does not change `/etc/nixos`. If Python 3 is missing, `./install.sh` adds it to the user Nix profile; declaring it in `configuration.nix` is still recommended.

## 1. Enable Hyprland and polkit

Add this to your existing `/etc/nixos/configuration.nix` module, then rebuild your normal NixOS configuration:

```nix
{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [
    git python3 bash
    waybar wofi swaynotificationcenter kitty alacritty thunar
    hyprlock wlogout quickshell ffmpeg
    grim slurp wl-clipboard libnotify
    fastfetch cava networkmanagerapplet blueman
    hyprpolkitagent
    awww pywal16
  ];
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono noto-fonts ];
}
```

Package attributes can differ across Nixpkgs channels. If evaluation reports a missing attribute, search your pinned channel with `nix search nixpkgs <name>` and adjust that entry. Make sure `wal`, `awww`, `awww-daemon`, and `quickshell` are on your session `PATH`; `./install.sh --check` lists any missing commands. Add `qt6.qtwayland` or other platform plugins if Quickshell cannot start in your Wayland session.

If you already use Home Manager, avoid managing the same `~/.config` paths twice. Disable Home Manager ownership of this rice's `hypr`, `waybar`, `world80-gallery`, and related folders before running the copying installer. You can instead manage those files declaratively yourself and use this guide only for dependencies. If Home Manager also enables Hyprland while UWSM is on, follow the [official NixOS guidance](https://wiki.nixos.org/wiki/Hyprland) to disable its conflicting systemd integration.

## 2. Enter Hyprland and install the config

Log into a Hyprland session first. The installer reads your current monitor modes, positions, scale, and keyboard options, so it must run from that session as your regular user.

```sh
git clone https://github.com/Teiguuu/dotfiles.git
cd dotfiles
./install.sh --check
./install.sh
hyprctl reload
~/.config/hypr/scripts/start-rice.sh
```

The clone URL above is the current repository origin; change it if this rice is published under a new name. Backups and a `restore.py` command are printed by the installer. The installer copies files to `~/.config` and `~/.local/share/teigu-rice`; it does not create Nix store links. New configurations may be overwritten by later Home Manager switches if you also declare those paths there.

## 3. Wallpapers and sessions

The repository includes only the original still wallpapers. The gallery discovers additional files under `~/Pictures/Wallpapers`. Your personal six MoeWalls videos and the World80 collection are recorded in [wallpaper-sources.json](wallpaper-sources.json). They are separate downloads and are not installed by `install.py` yet.

If you use a user systemd service to launch apps, ensure it receives the Hyprland and Wayland environment. The [Hyprland Home Manager guide](https://wiki.hypr.land/nix/configuring-hyprland-with-home-manager/) explains this when using Home Manager. The rice itself launches its shell components from the Hyprland session.

## Restore

Run the exact `python3 /path/to/restore.py` command printed by the installer, then log out and back in. The restore script moves replaced files into that backup folder rather than discarding them.
