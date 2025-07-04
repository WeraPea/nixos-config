{
  nixpkgs.overlays = [
    (import ./otd.nix)
    (import ./waybar.nix)
  ];
}
