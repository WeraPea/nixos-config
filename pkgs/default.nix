pkgs: {
  ruler = pkgs.callPackage ./ruler.nix { };
  minimap = pkgs.callPackage ./minimap.nix { };
  equalizer = pkgs.callPackage ./equalizer.nix { };
  progressbar = pkgs.callPackage ./progressbar.nix { };
  status-line = pkgs.callPackage ./status-line.nix { };
  detect-image = pkgs.callPackage ./detect-image.nix { };
  freeze-window = pkgs.callPackage ./freeze-window.nix { };
  image-positioning = pkgs.callPackage ./image-positioning.nix { };
}
