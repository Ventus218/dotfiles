{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = "alessandro";
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/nvim.nix
    ./modules/ghostty.nix
  ];

  options.my.dotfilesDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/dotfiles";
    description = ''
      Path to the dotfiles checkout.

      The "live" files in the modules below are symlinked to this path at
      activation time, so it must be stable and writable (outside the nix
      store). Move the repo to {file}`~/dotfiles`, or override this option.
    '';
  };

  config = {
    # Explicit instead of builtins.getEnv: keeps evaluation pure, so
    # `nix flake check` / CI / remote builders see the same values.
    home.username = username;
    home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    home.stateVersion = "26.05";

    # Let home-manager install itself from this flake's pinned input.
    programs.home-manager.enable = true;
  };
}
