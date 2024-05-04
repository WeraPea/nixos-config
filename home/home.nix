{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./programs
    ./scripts
  ];

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
