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


# MacOS specific setup
if [[ "$OSTYPE" == darwin* ]]; then
    :
fi

# Packages

# install brew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install pure (prompt theme)
# MacOS: brew install pure
# Linux: mkdir -p "$HOME/.zsh"; git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
