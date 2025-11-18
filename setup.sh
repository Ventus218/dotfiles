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

# ~~~~~~~~~~~~~~~~~ Util functions ~~~~~~~~~~~~~~~~~

command_exists() {
    command -v "$@" >/dev/null
}

# This way if sudo does not exists we can make it a nop
if ! command_exists sudo; then
    sudo() { "$@"; }
fi

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

# ~~~~~~~~~~~~~~~~~ Check tools needed for setup ~~~~~~~~~~~~~~~~~

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

if [ "$DISTRO_BASE" = "$MACOS" ]; then
    echo Installing Homebrew...
    check_tool_or_exit curl
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ~~~~~~~~~~~~~~~~~ Installing main development tools ~~~~~~~~~~~~~~~~~

echo "Installing main development tools..."
COMMON="git"
case $DISTRO_BASE in
"$MACOS")
    # shellcheck disable=SC2086
    brew install $COMMON

    brew install node@24
    ;;
"$DEBIAN")
    sudo apt-get update
    # shellcheck disable=SC2086
    sudo apt-get install -y $COMMON

    sudo apt-get install -y zsh

    sudo apt-get install -y curl

    curl -fsSL https://deb.nodesource.com/setup_24.x | sudo bash -
    # Original command was this, hope removing -E doesn't break anything
    # curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    ;;
"$FEDORA")
    # shellcheck disable=SC2086
    sudo dnf -y install $COMMON

    sudo dnf -y install zsh

    sudo dnf -y install curl

    sudo dnf -y install curl
    curl -fsSL https://rpm.nodesource.com/setup_24.x | sudo bash -
    sudo dnf -y install nodejs
    ;;
esac
unset COMMON

echo Setting zsh as default shell...
case $OS in
"$LINUX")
    chsh -s "$(command -v zsh)" || echo "Unable to set zsh as default shell"
    ;;
esac

if ! command_exists nvim; then
    echo Installing NeoVim...
    case $OS in
    "$MACOS")
        brew install nvim
        ;;
    "$LINUX")
        ARCH=$(uname -m)
        [ "$ARCH" != "x86_64" ] && ARCH="arm64"
        NVIM_APPIMAGE="nvim-linux-$ARCH.appimage"
        curl -LO "https://github.com/neovim/neovim/releases/latest/download/$NVIM_APPIMAGE"
        chmod u+x "$NVIM_APPIMAGE"
        "./$NVIM_APPIMAGE" --appimage-extract
        rm "$NVIM_APPIMAGE"
        sudo mv squashfs-root /nvim-appimage
        sudo ln -s /nvim-appimage/AppRun /usr/bin/nvim
        unset ARCH
        ;;
    esac
fi

# ~~~~~~~~~~~~~~~~~ Install Pure (propmt theme) ~~~~~~~~~~~~~~~~~

case $OS in
"$MACOS")
    brew install pure
    ;;
"$LINUX")
    mkdir -p "$HOME/.zsh"
    PURE_DIR="$HOME/.zsh/pure"
    if [ -d "$PURE_DIR" ]; then
        echo "Pure (prompt theme) already installed in $PURE_DIR"
    else
        git clone https://github.com/sindresorhus/pure.git "$PURE_DIR"
    fi
    ;;
esac
