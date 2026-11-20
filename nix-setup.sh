#!/usr/bin/env bash
# Bootstrap Nix + Home Manager and apply this repo's configuration.
#
#   ./nix-setup.sh          # detect the host from uname (mac | linux)
#   ./nix-setup.sh mac      # explicit host name, must exist in flake.nix
#
# The home-manager configuration never copies files into the nix store: the
# live configs are symlinked to paths under ~/dotfiles. This script makes sure
# the checkout is reachable from there.

set -e

REPO_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_LINK="$HOME/dotfiles"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# ~~~~~~~~~~~~~~~~~ Util functions ~~~~~~~~~~~~~~~~~

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

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
}

# sudo does not exist in some containers, make it a no-op there
if ! command_exists sudo; then
    sudo() { "$@"; }
fi

# ~~~~~~~~~~~~~~~~~ Make the checkout reachable at ~/dotfiles ~~~~~~~~~~~~~~~~~

if [ "$REPO_DIR" != "$REPO_LINK" ]; then
    if [ -e "$REPO_LINK" ] || [ -L "$REPO_LINK" ]; then
        echo "$REPO_LINK already exists but is not this checkout."
        echo "Move the repo to $REPO_LINK (or remove that path) and re-run this script."
        exit 1
    fi
    ln -s "$REPO_DIR" "$REPO_LINK"
    echo "Linked $REPO_LINK -> $REPO_DIR"
fi

# ~~~~~~~~~~~~~~~~~ Pick the host ~~~~~~~~~~~~~~~~~

HOST=${1:-}
if [ -z "$HOST" ]; then
    case "$(uname)" in
    Darwin) HOST=mac ;;
    Linux) HOST=linux ;;
    *)
        echo "Unsupported operating system: $(uname)."
        echo "Pass one of the host names from flake.nix, e.g.: ./nix-setup.sh linux"
        exit 1
        ;;
    esac
fi

# ~~~~~~~~~~~~~~~~~ Install Nix ~~~~~~~~~~~~~~~~~

if ! command_exists nix; then
    echo "Installing Nix..."
    # xz is needed to unpack the nix store, curl to download the installer
    check_tool_or_exit curl xz
    case "$(uname)" in
    Darwin)
        sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
        ;;
    Linux)
        sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
        ;;
    esac
fi

# Make nix available in this shell
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
if ! command_exists nix; then
    echo "nix is not on PATH. Open a new shell and re-run this script."
    exit 1
fi

# Flakes are still behind an experimental feature flag in upstream Nix
NIX_CONF="$XDG_CONFIG_HOME/nix/nix.conf"
mkdir -p "$XDG_CONFIG_HOME/nix"
if ! grep -qs '^experimental-features' "$NIX_CONF"; then
    echo 'experimental-features = nix-command flakes' >>"$NIX_CONF"
    echo "Enabled flakes in $NIX_CONF"
fi

# ~~~~~~~~~~~~~~~~~ Drop the old channel-based entry point ~~~~~~~~~~~~~~~~~

# Previous versions of this script symlinked ~/.config/home-manager/home.nix to
# the repo. The configuration now lives in nix/home.nix and is used through
# `--flake`, so that link would only point at a stale path.
OLD_LINK="$XDG_CONFIG_HOME/home-manager/home.nix"
if [ -L "$OLD_LINK" ]; then
    case "$(readlink "$OLD_LINK")" in
    "$REPO_DIR/home.nix" | */dotfiles/home.nix)
        rm -f "$OLD_LINK"
        echo "Removed stale $OLD_LINK (configuration moved to nix/home.nix)"
        ;;
    esac
fi

# ~~~~~~~~~~~~~~~~~ Apply the configuration ~~~~~~~~~~~~~~~~~

echo "Applying home-manager configuration '$HOST'..."
# `-b backup` moves pre-existing files (e.g. a .zshrc symlinked by the old
# setup.sh) out of the way instead of aborting the first activation.
# Use the real checkout path here (not the ~/dotfiles symlink): the flake is
# read from REPO_DIR, while the activation symlinks use my.dotfilesDir.
nix run "$REPO_DIR#home-manager" -- switch -b backup --flake "$REPO_DIR#$HOST"

# ~~~~~~~~~~~~~~~~~ Shell setup ~~~~~~~~~~~~~~~~~

case "$(uname)" in
Linux)
    # The nix profile may have grown during the switch
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    ZSH=$(command -v zsh || true)
    if [ -n "$ZSH" ] && [ "${SHELL:-}" != "$ZSH" ]; then
        if ! grep -qx "$ZSH" /etc/shells 2>/dev/null; then
            echo "$ZSH" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$ZSH" </dev/null ||
            echo "Could not change the login shell, run: chsh -s $ZSH"
    fi
    ;;
esac

echo
echo "Finished! Open a new shell, then:"
echo "  home-manager switch --flake $REPO_LINK#$HOST   # after editing nix/"
echo "  nvim                                           # after editing nvim/"
