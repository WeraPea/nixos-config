pkgs:
let
  callPackage = pkgs.callPackage;
in
rec {
  _0x0 = callPackage ./0x0.nix { };
  anacreon-mpv-script = callPackage ./anacreon-mpv-script.nix { };
  anki-helper = callPackage ./anki-helper.nix { inherit screenshot; };
  anki-koplugin = callPackage ./anki-koplugin.nix { };
  aria2dl = callPackage ./aria2dl.nix { };
  beets-vocadb = callPackage ./beets-vocadb.nix { inherit httpx-retries; };
  browserexport = callPackage ./browserexport.nix { inherit kompress sqlite-backup; };
  httpx-retries = pkgs.python3.pkgs.callPackage ./httpx-retries.nix { };
  kompress = pkgs.python3.pkgs.callPackage ./kompress.nix { };
  launch-osu = callPackage ./launch-osu.nix { inherit osu-scrobbler; };
  mpv-http-mitmytproxy = callPackage ./mpv-http-mitmytproxy.nix { };
  mpv-websocket = callPackage ./mpv-websocket.nix { };
  mpv-websocket-script = callPackage ./mpv-websocket-script.nix { inherit mpv-websocket; };
  mpv-youtube-srv3-subs = callPackage ./mpv-youtube-srv3-subs.nix { inherit yt-sub-converter; };
  nyaasi = callPackage ./nyaasi.nix { };
  osu-scrobbler = callPackage ./osu-scrobbler.nix { };
  pinenote-dither-sync = callPackage ./pinenote-dither-sync.nix { };
  pinenote-screenshot = callPackage ./pinenote-screenshot.nix { };
  progressbar = callPackage ./progressbar.nix { };
  rakuyomi = callPackage ./rakuyomi.nix { };
  rename-torrents = callPackage ./rename-torrents.nix { };
  rotate = callPackage ./rotate.nix { };
  screenshot = callPackage ./screenshot.nix { };
  search = callPackage ./search.nix { inherit nyaasi; };
  sony-headphones-client = callPackage ./sony-headphones-client.nix { };
  sqlite-backup = pkgs.python3.pkgs.callPackage ./sqlite-backup.nix { };
  streamlink-ttvlol = callPackage ./streamlink-ttvlol.nix { };
  switch-boot-partition = callPackage ./switch-boot-partition.nix { };
  udev-gothic-hs-nf = callPackage ./udev-gothic-hs-nf.nix { };
  usb-tablet = callPackage ./usb-tablet.nix { };
  vrlink = callPackage ./vrlink.nix { };
  yomitan-api = callPackage ./yomitan-api.nix { };
  yomitan-ultimate-audio = callPackage ./yomitan-ultimate-audio.nix { };
  yt-sub-converter = callPackage ./yt-sub-converter.nix { };
}
