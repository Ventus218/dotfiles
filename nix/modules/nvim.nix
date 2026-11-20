{ config, ... }:

{
  # Tier 2: one symlink to the live directory in the repo.
  #
  # Do not set `recursive = true`: that would rebuild the directory as one
  # symlink per file, freezing the file list at build time, so new plugin
  # files would stay invisible until the next switch.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesDir}/nvim";
}
