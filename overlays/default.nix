{ lib, ... }:
{
  nixpkgs.overlays = lib.mkAfter [
    (import ./otd.nix)
    (import ./monado.nix)
    (import ./xrizer.nix)
    (import ./opencomposite.nix)
    (import ./bs-manager.nix)
    (import ./glide.nix)
  ];
}
