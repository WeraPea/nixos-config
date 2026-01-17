pkgs:
let
  callPackage = pkgs.callPackage;
in
rec {
  _0x0 = callPackage ./0x0.nix { };
  anacreon-mpv-script = callPackage ./anacreon-mpv-script.nix { };
  anki-koplugin = callPackage ./anki-koplugin.nix { };
  aria2dl = callPackage ./aria2dl.nix { };
  beets-vocadb = callPackage ./beets-vocadb.nix { };
  launch-osu = callPackage ./launch-osu.nix { };
  manga-ocr = callPackage ./manga-ocr.nix { };
  manga-ocr-from-file = callPackage ./manga-ocr-from-file.nix { inherit manga-ocr; };
  mpv-http-mitmytproxy = callPackage ./mpv-http-mitmytproxy.nix { };
  mpv-websocket = callPackage ./mpv-websocket.nix { };
  mpv-websocket-script = callPackage ./mpv-websocket-script.nix { inherit mpv-websocket; };
  mpv-youtube-srv3-subs = callPackage ./mpv-youtube-srv3-subs.nix { inherit yt-sub-converter; };
  nyaasi = callPackage ./nyaasi.nix { };
  progressbar = callPackage ./progressbar.nix { };
  rakuyomi = callPackage ./rakuyomi.nix { };
  rename-torrents = callPackage ./rename-torrents.nix { };
  rotate = callPackage ./rotate.nix { };
  screenshot = callPackage ./screenshot.nix { inherit manga-ocr-from-file; };
  search = callPackage ./search.nix { inherit nyaasi; };
  sony-headphones-client = callPackage ./sony-headphones-client.nix { };
  streamlink-ttvlol = callPackage ./streamlink-ttvlol.nix { };
  switch-boot-partition = callPackage ./switch-boot-partition.nix { };
  udev-gothic-hs-nf = callPackage ./udev-gothic-hs-nf.nix { };
  usb-tablet = callPackage ./usb-tablet.nix { };
  vrlink = callPackage ./vrlink.nix { };
  yt-sub-converter = callPackage ./yt-sub-converter.nix { };
}
