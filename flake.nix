{
  description = "Alessandro's dotfiles";

  inputs = {
    # 26.05 is the last nixpkgs release that supports x86_64-darwin (Intel
    # macOS). When this machine is replaced by an Apple Silicon one, bump both
    # inputs to 26.11 (or nixos-unstable) and update `hosts` below.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      # One line per machine: the name is what you pass to `--flake .#<name>`.
      hosts = {
        mac = "x86_64-darwin";
        linux = "x86_64-linux";
        # wsl = "x86_64-linux";
      };

      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ ./nix/home.nix ];
        };
    in
    {
      homeConfigurations = nixpkgs.lib.mapAttrs (_: mkHome) hosts;

      # Lets the bootstrap script use *this* flake's pinned Home Manager:
      #   nix run .#home-manager -- switch --flake ~/dotfiles#mac
      packages = nixpkgs.lib.genAttrs (nixpkgs.lib.attrValues hosts) (system: {
        home-manager = home-manager.packages.${system}.home-manager;
      });
    };
}
