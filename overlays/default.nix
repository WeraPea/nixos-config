{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./otd.patch # configuration and parser for pinenote when connected over usb gadget otg
        ];
      });
    })
  ];
}
