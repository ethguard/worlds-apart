#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

install_python() {
    if command -v nix >/dev/null 2>&1 && [ -f /etc/NIXOS ]; then
        printf '%s\n' 'Installing Python 3 into your Nix user profile…'
        nix --extra-experimental-features 'nix-command flakes' profile install nixpkgs#python3
        PATH="$HOME/.nix-profile/bin:$HOME/.local/state/nix/profile/bin:$PATH"
        export PATH
        return
    fi

    if [ "$(id -u)" -eq 0 ]; then
        manager=''
    elif command -v sudo >/dev/null 2>&1; then
        manager=sudo
    elif command -v doas >/dev/null 2>&1; then
        manager=doas
    elif command -v pkexec >/dev/null 2>&1; then
        manager=pkexec
    else
        printf '%s\n' 'No sudo, doas, or pkexec found. Install Python 3 using your system administrator account.' >&2
        return 1
    fi

    printf '%s\n' 'Installing Python 3 with the available package manager…'
    if command -v pacman >/dev/null 2>&1; then
        ${manager:+$manager} pacman -S --needed python
    elif command -v apt-get >/dev/null 2>&1; then
        ${manager:+$manager} apt-get update
        ${manager:+$manager} apt-get install python3
    elif command -v dnf >/dev/null 2>&1; then
        ${manager:+$manager} dnf install python3
    elif command -v zypper >/dev/null 2>&1; then
        ${manager:+$manager} zypper install python3
    elif command -v apk >/dev/null 2>&1; then
        ${manager:+$manager} apk add python3
    elif command -v xbps-install >/dev/null 2>&1; then
        ${manager:+$manager} xbps-install -S python3
    elif command -v emerge >/dev/null 2>&1; then
        ${manager:+$manager} emerge dev-lang/python
    elif command -v eopkg >/dev/null 2>&1; then
        ${manager:+$manager} eopkg install python3
    else
        printf '%s\n' 'No supported package manager found. Install Python 3 with your distribution package manager.' >&2
        return 1
    fi
}

if ! command -v python3 >/dev/null 2>&1; then
    if [ "${1:-}" = '--check' ]; then
        printf '%s\n' 'Python 3 is missing. Run ./install.sh to install it and continue.' >&2
        exit 1
    fi
    install_python
fi

if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'Python 3 installation finished, but python3 is not on PATH. Open a new shell and rerun ./install.sh.' >&2
    exit 1
fi
exec python3 "$repo_dir/install.py" "$@"
