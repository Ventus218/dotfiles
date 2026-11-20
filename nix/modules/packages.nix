{ pkgs, lib, ... }:

{
  # Tier 1: things that should be installed, versioned and reproducible.
  # Add tools here; changing this list is the only thing that needs a
  # `home-manager switch` besides nix changes.
  home.packages =
    with pkgs;
    [
      # Shell and prompt (pure is still loaded from .zshrc manually)
      zsh
      pure-prompt

      # Base tooling
      git
      gnumake
      curl

      # Neovim toolchain: lazy.nvim + mason still manage plugins/LSes
      # themselves, these are the runtimes they need.
      nodejs
      tree-sitter
      neovim
    ]
    # On macOS a C compiler comes from the Xcode command line tools; on
    # Linux we need one for nvim-treesitter parser builds.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ gcc ];
}
