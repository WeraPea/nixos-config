{
  imports = [
    ./programs
    ./scripts
    ./../overlays
  ];

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
