#!/bin/sh

set -e

# Assuming this script is in the dotfile repo root
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

XDG_CONFIG_HOME="$HOME/.config"
mkdir -p $XDG_CONFIG_HOME

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

# ~~~~~~~~~~~~~~~~~ Detecting OS and DISTRO ~~~~~~~~~~~~~~~~~

OS=
# OS will be set to one of the following values in order to ease switch cases
MACOS=Darwin
LINUX=Linux

DISTRO=
# DISTRO will be set to one of the following values or to OS if distros
# of that OS do not exist
# UBUNTU=Ubuntu
# FEDORA=Fedora

case "$(uname)" in
    Darwin)
        OS=$MACOS
        ;;
    Linux)
        OS=$LINUX
        # Here we may do additional checks to detect the distribution
        ;;
    *)
        echo "Unexpected operating system $(uname)"
        exit 1
        ;;
esac

if [ -z $DISTRO ]; then
    DISTRO=$OS
fi

if [[ "$DISTRO" == "$MACOS" ]]; then
    # install brew
    # TODO: use POSIX tool
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


# install pure (prompt theme)
# MacOS: brew install pure
# Linux: mkdir -p "$HOME/.zsh"; git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
