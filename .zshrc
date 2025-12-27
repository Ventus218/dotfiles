# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

export VISUAL=nvim
export EDITOR=nvim

# Directories

# Follow .zshrc symlink
DOTFILES=$(readlink "$HOME/.zshrc")
if [ -n "$DOTFILES" ]; then
    # We assume its target is inside the dotfiles repo
    export DOTFILES=$(dirname "$DOTFILES")
else
    echo "Unable to find the dotfiles repo"
    unset DOTFILES
fi


# ~~~~~~~~~~~~~~~ VI mode ~~~~~~~~~~~~~~~~~~~~~~~~

# Activate vi mode
bindkey -v

# Allow backspace to delete already inserted text
bindkey -M viins '^?' backward-delete-char # default is "vi-backward-delete-char"

# Ctrl-L acts like Esc
bindkey -M viins '^L' vi-cmd-mode
bindkey -M vicmd '^L' vi-cmd-mode

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~


# Note: in zsh path is tied to PATH

# Remove duplicate entries and non-existent directories
typeset -U path

export PATH


# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~


HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
# setopt SHARE_HISTORY      # Share history between sessions


# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~


# Pure (https://github.com/sindresorhus/pure)
if [[ "$OSTYPE" == darwin* ]]; then
    fpath+=("$(brew --prefix)/share/zsh/site-functions")
else
    fpath+=($HOME/.zsh/pure)
fi
autoload -U promptinit; promptinit
prompt pure


# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~


alias v=nvim


# ~~~~~~~~~~~~~~~ Completion ~~~~~~~~~~~~~~~~~~~~~~~~


if command -v brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit -u

zstyle ':completion:*' menu select


# ~~~~~~~~~~~~~~~ Misc ~~~~~~~~~~~~~~~~~~~~~~~~


# set -o vi

# ~~~~~~~~~~~~~~~ Sourcing .zshrc.local ~~~~~~~~~~~~~~~~~~~~~~~~


# In case some configuration should not be commited to the dotfiles repo
# we source it from a .zshrc.local file
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
