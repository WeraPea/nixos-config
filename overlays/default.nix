{
  nixpkgs.overlays = [
    (import ./otd.nix)
    (import ./anki.nix)
  ];
}
