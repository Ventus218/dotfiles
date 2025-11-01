#!/bin/bash

set -e

# Assuming this script is in the dotfile repo root
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

XDG_CONFIG_HOME="$HOME/.config"
mkdir -p $XDG_CONFIG_HOME

create_symlinks() {
    local items=("$@")
    for item in "${items[@]}"; do
        IFS=':' read -r source target <<<"$item"
        if [ -L "$target" ]; then
            echo "Removing existing symlink $target"
            unlink "$target"
        elif [ -d "$target" ]; then
            echo "Warning: $target is a directory. Skipping..."
            continue
        elif [ -e "$target" ]; then
            echo "Warning: $target already exists. Skipping..."
            continue
        fi
        ln -s "$DOTFILES_DIR/$source" "$target"
        echo "Created symlink for $source"
    done
}

common_items=(
    "nvim:$XDG_CONFIG_HOME/nvim"
    ".zprofile:$HOME/.zprofile"
    ".zshrc:$HOME/.zshrc"
)

create_symlinks "${common_items[@]}"

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
