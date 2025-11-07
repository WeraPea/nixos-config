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
  yt-sub-converter = pkgs.callPackage ./yt-sub-converter.nix { };
  mpv-youtube-srv3-subs = pkgs.callPackage ./mpv-youtube-srv3-subs.nix {
    yt-sub-converter = pkgs.callPackage ./yt-sub-converter.nix { };
  };
  usb-tablet = pkgs.callPackage ./usb-tablet.nix { };
  udev-gothic-hs-nf = pkgs.callPackage ./udev-gothic-hs-nf.nix { };
  launch-osu = pkgs.callPackage ./launch-osu.nix { };
  anacreon-mpv-script = pkgs.callPackage ./anacreon-mpv-script.nix {
    inherit (pkgs.mpvScripts) buildLua;
  };
  mpv-websocket-script = pkgs.callPackage ./mpv-websocket-script.nix {
    inherit (pkgs.mpvScripts) buildLua;
  };
  anki-koplugin = pkgs.callPackage ./anki-koplugin.nix {};
}
