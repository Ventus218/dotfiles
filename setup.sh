#!/bin/sh

set -e

# Assuming this script is in the dotfile repo root
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME"

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

create_symlinks \
    "nvim:$XDG_CONFIG_HOME/nvim" \
    ".zprofile:$HOME/.zprofile" \
    ".zshrc:$HOME/.zshrc"

# ~~~~~~~~~~~~~~~~~ Detecting OS, DISTRO_BASE and DISTRO ~~~~~~~~~~~~~~~~~

# OS will be set to one of the following values in order to ease switch cases
OS=
MACOS=Darwin
LINUX=Linux

# DISTRO_BASE will be set to one of the following values or to OS if distros
# of that OS do not exist
DISTRO_BASE=
DEBIAN=Debian
# RED_HAT=RedHat

# DISTRO will be set to one of the following values or to DISTRO_BASE
# if it was impossible to detect a specific distro
DISTRO=
# UBUNTU=Ubuntu
# FEDORA=Fedora

case "$(uname)" in
Darwin)
    OS=$MACOS
    ;;
Linux)
    OS=$LINUX
    if command_exists apt; then
        DISTRO_BASE=$DEBIAN
    else
        echo "Unexpected distribution. Right now only Debian-based (apt) distros are supported."
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

if [ "$DISTRO" = "$MACOS" ]; then
    # install brew
    # TODO: use POSIX tool
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ~~~~~~~~~~~~~~~~~ Install Pure (propmt theme) ~~~~~~~~~~~~~~~~~

case $OS in
"$MACOS")
    brew install pure
    ;;
"$LINUX")
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
    ;;
esac
