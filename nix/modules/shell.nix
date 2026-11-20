{ config, ... }:

{
  # Tier 2: these stay real files in the repo, so editing them is instant and
  # needs no rebuild.
  #
  # Home Manager only guarantees that `zsh` is installed (see packages.nix).
  # It does not source `hm-session-vars.sh` here; `home.sessionVariables` and
  # `home.sessionPath` only take effect once this is converted to
  # `programs.zsh.enable = true` (a later, optional step).
  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesDir}/.zshrc";
  home.file.".zprofile".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesDir}/.zprofile";
}
