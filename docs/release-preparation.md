# Release preparation

Pushed to the public fork at https://github.com/yxzroot/dotfiles on 2026-10-29. This is a repository push, not a tagged GitHub release.

Completed:

- Replaced the outdated README with feature descriptions, current bindings, compatibility notes, and three selected screenshots.
- Added direct upstream credits, configured Neovim plugin credits, and third-party license notices.
- Removed personal hardware/host labels from the repository Fastfetch config; live desktop settings were not changed.
- Added ignore rules for local display overrides, backup files, caches, and downloaded video files.
- Kept downloaded wallpaper collections outside the repository.

Still to decide with the maintainer:

- Installer preflight and distro-neutral config copying are implemented; package installation and the preview-based wallpaper chooser remain open. Six personal wallpaper source pages are confirmed in `docs/moewalls-wallpapers.json`. The MediaFire folder with six videos and 17 original stills, and the separate World80 GitHub source, are recorded in `docs/wallpaper-sources.json`. Redistribution terms still need review.
- Project name and tagged release version. The public fork is yxzroot/dotfiles, with Teiguuu/dotfiles retained as upstream.
- Project licensing and unresolved upstream/artwork permissions listed in `THIRD_PARTY.md`.

Compatibility notes:

- Development system: CachyOS / Arch, Hyprland 0.57.0. No fresh-system install has been validated.
- The original battery-limit scripts target `ideapad-cm`; laptop modules require hardware adaptation.
- Repository `system/pkglist.txt` is inherited package inventory, not a reviewed minimal dependency list.
- Screenshots retain the appearance of the personal desktop, including host/user display and Wi-Fi SSID.
- Earlier upstream preview images remain in `screenshots/1preview.png` and `2preview.png` for provenance; the README uses the three new images.
