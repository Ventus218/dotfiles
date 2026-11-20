# nix/

How the home-manager side of the dotfiles is organised.

## Layout

```
flake.nix              # pinned inputs + one output per machine
nix/home.nix           # identity (user, home dir, stateVersion) + imports
nix/modules/*.nix      # packages and configs, one concern per file
```

`flake.nix` has a `hosts` attr: host name (used in `--flake .#<name>`) to nix
system. Add a machine by adding a line there and applying it.

## The one rule

| What | Where | Rebuild needed |
| --- | --- | --- |
| Tools, versions, PATH/env | `nix/modules/packages.nix` | `home-manager switch` |
| `nvim/`, `.zshrc`, `ghostty/` | `nix/modules/*.nix` symlink to the repo | **no** |
| lazy.nvim plugins, mason tools, history | the tool itself (`~/.local/share`) | no |

`nix/modules/shell.nix`, `nvim.nix` and `ghostty.nix` use
`mkOutOfStoreSymlink`: the target is `~/dotfiles/<path>`, so the repo must live
there (this is what `../nix-setup.sh` guarantees). Do not add `recursive = true`
to a directory symlink: it freezes the file list at build time.

## Daily use

```sh
home-manager switch --flake ~/dotfiles#mac    # after editing nix/
nix run .#home-manager -- switch --flake ~/dotfiles#mac
home-manager generations                     # roll back with switch --rollback
```

`flake.lock` is generated on the first run and should be committed: it is what
makes the setup reproducible.

## Pinned to 26.05 on purpose

`x86_64-darwin` (Intel macOS) is supported by nixpkgs **26.05 only**; 26.11+
dropped it and nixpkgs 26.05 reaches end of support at the end of 2026. When
the Mac is replaced (Apple Silicon) or Linux-only, bump both inputs in
`flake.nix` and update `hosts.mac`.

CI mirrors this: `test_flake.yaml` evaluates every host on Linux and builds
each host on a native runner (`macos-15-intel` is the last Intel image).

## Later, when you want it

- Move `.zshrc` to `programs.zsh` so `home.sessionVariables`/`sessionPath` get
  sourced (then set `initContent = "source ~/dotfiles/zsh/rc.zsh"` to keep the
  body live-editable).
- Add nix-darwin for Homebrew casks and macOS defaults; home-manager can then
  manage system-level pieces too.
