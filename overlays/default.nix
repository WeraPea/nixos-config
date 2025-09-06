{
  nixpkgs.overlays = [
    (import ./otd.nix)
    (import ./monado.nix)
    (import ./opencomposite.nix)
    (import ./bs-manager.nix)
  ];
}
