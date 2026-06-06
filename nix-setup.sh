#!/bin/bash
# TODO: see if we can use sh instead of bash

set -e

# Assuming this script is in the dotfile repo root
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME"

# ~~~~~~~~~~~~~~~~~ Util functions ~~~~~~~~~~~~~~~~~

command_exists() {
    command -v "$@" >/dev/null
}

# This way if sudo does not exists we can make it a nop
if ! command_exists sudo; then
    sudo() { "$@"; }
fi

check_tool_or_exit() {
    EXIT=false
    for TOOL in "$@"; do
        if ! command_exists "$TOOL"; then
            echo "$TOOL is needed for this setup, install it and re-run this script"
            EXIT=true
        fi
    done
    if $EXIT; then
        exit 1
    fi
    unset EXIT
    unset TOOL
}

create_symlinks() {
    for ITEM in "$@"; do
        SOURCE=$(echo "$ITEM" | cut -d':' -f1)
        TARGET=$(echo "$ITEM" | cut -d':' -f2)
        if [ -L "$TARGET" ]; then
            echo "Removing existing symlink $TARGET"
            unlink "$TARGET"
        elif [ -d "$TARGET" ]; then
            echo "Warning: $TARGET is a directory. Skipping..."
            continue
        elif [ -e "$TARGET" ]; then
            echo "Warning: $TARGET already exists. Skipping..."
            continue
        fi
        ln -s "$DOTFILES_DIR/$SOURCE" "$TARGET"
        echo "Created symlink for $SOURCE"
    done
}

# ~~~~~~~~~~~~~~~~~ Detecting OS, DISTRO_BASE and DISTRO ~~~~~~~~~~~~~~~~~

# OS will be set to one of the following values in order to ease switch cases
OS=
MACOS=Darwin
LINUX=Linux

# DISTRO_BASE will be set to one of the following values or to OS if distros
# of that OS do not exist
DISTRO_BASE=
DEBIAN=Debian
FEDORA=Fedora
# RED_HAT=RedHat

# DISTRO will be set to one of the following values or to DISTRO_BASE
# if it was impossible to detect a specific distro
DISTRO=
# UBUNTU=Ubuntu
# NOBARA=Nobara

case "$(uname)" in
Darwin)
    OS=$MACOS
    ;;
Linux)
    OS=$LINUX
    if command_exists apt-get; then
        DISTRO_BASE=$DEBIAN
    elif command_exists dnf; then
        DISTRO_BASE=$FEDORA
    else
        echo "Unexpected distribution."
        echo "Right now only Debian-based (apt) and Fedora-based (dnf) distros are supported."
        exit 1
    fi
    # Here we may do additional checks to set DISTRO
    ;;
*)
    echo "Unexpected operating system $(uname)"
    exit 1
    ;;
esac

if [ -z "$DISTRO_BASE" ]; then
    DISTRO_BASE=$OS
fi
if [ -z "$DISTRO" ]; then
    DISTRO=$DISTRO_BASE
fi

# ~~~~~~~~~~~~~~~~~ Install Nix ~~~~~~~~~~~~~~~~~

echo Installing Nix ...
#xz package is xz-utils, also check if it is needed in macos or only on linux
check_tool_or_exit curl xz
case $OS in
"$LINUX")
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
    ;;
"$MACOS")
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
    ;;
esac
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# ~~~~~~~~~~~~~~~~~ Install (Nix) Home Manager ~~~~~~~~~~~~~~~~~

echo "Installing (Nix) Home Manager ..."
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
HOME_DOT_NIX_FILE_LOCATION="$XDG_CONFIG_HOME/home-manager/home.nix"
echo "Deleting default $HOME_DOT_NIX_FILE_LOCATION file"
rm "$HOME_DOT_NIX_FILE_LOCATION"
echo "Symlinking $DOTFILES_DIR/home.nix to $HOME_DOT_NIX_FILE_LOCATION"
create_symlinks \
    "home.nix:$HOME_DOT_NIX_FILE_LOCATION"
