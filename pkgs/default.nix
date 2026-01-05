pkgs: {
  progressbar = pkgs.callPackage ./progressbar.nix { };
  streamlink-ttvlol = pkgs.callPackage ./streamlink-ttvlol.nix { };
  yt-sub-converter = pkgs.callPackage ./yt-sub-converter.nix { };
  usb-tablet = pkgs.callPackage ./usb-tablet.nix { };
  udev-gothic-hs-nf = pkgs.callPackage ./udev-gothic-hs-nf.nix { };
  launch-osu = pkgs.callPackage ./launch-osu.nix { };
  anacreon-mpv-script = pkgs.callPackage ./anacreon-mpv-script.nix { };
  mpv-websocket = pkgs.callPackage ./mpv-websocket.nix { };
  mpv-websocket-script = pkgs.callPackage ./mpv-websocket-script.nix {
    mpv-websocket = pkgs.callPackage ./mpv-websocket.nix { };
  };
  anki-koplugin = pkgs.callPackage ./anki-koplugin.nix { };
  manga-ocr = pkgs.callPackage ./manga-ocr.nix { };
  manga-ocr-from-file = pkgs.callPackage ./manga-ocr-from-file.nix {
    manga-ocr = pkgs.callPackage ./manga-ocr.nix { };
  };
  sony-headphones-client = pkgs.callPackage ./sony-headphones-client.nix { };
  beets-vocadb = pkgs.callPackage ./beets-vocadb.nix { };
  mpv-http-mitmytproxy = pkgs.callPackage ./mpv-http-mitmytproxy.nix { };
  mpv-youtube-srv3-subs = pkgs.callPackage ./mpv-youtube-srv3-subs.nix {
    yt-sub-converter = pkgs.callPackage ./yt-sub-converter.nix { };
  };
}
