{
  nixpkgs.overlays = [
    (import ./otd.nix)
  ];
}
