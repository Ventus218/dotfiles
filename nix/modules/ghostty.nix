{ config, ... }:

{
  # Tier 2: live file. Kept as a plain symlink on purpose, `programs.ghostty`
  # would generate the config from nix and require a rebuild per edit.
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesDir}/ghostty";
}
