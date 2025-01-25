pkgs: {
  blender = pkgs.callPackage ./blender.nix { };
  detect-image = pkgs.callPackage ./detect-image.nix { };
  equalizer = pkgs.callPackage ./equalizer.nix { };
  freeze-window = pkgs.callPackage ./freeze-window.nix { };
  image-positioning = pkgs.callPackage ./image-positioning.nix { };
  minimap = pkgs.callPackage ./minimap.nix { };
  progressbar = pkgs.callPackage ./progressbar.nix { };
  ruler = pkgs.callPackage ./ruler.nix { };
  status-line = pkgs.callPackage ./status-line.nix { };
  streamlink-ttvlol = pkgs.callPackage ./streamlink-ttvlol.nix { };
  webtorrent-mpv-hook = pkgs.callPackage ./webtorrent-mpv-hook.nix { };
}
