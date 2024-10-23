{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.packages =
    with pkgs;
    let
      aria2dl = writeShellScriptBin "aria2dl" (builtins.readFile ./aria2dl.sh);
      audiorelay = writeShellScriptBin "audiorelay-wrapper" (
        builtins.readFile (substituteAll {
          src = ./audiorelay.sh;
          xdotool = "${lib.getExe xdotool}";
          xvfb = "${lib.getExe' xorg.xvfb "Xvfb"}";
          pactl = ''${lib.getExe' pulseaudio "pactl"}'';
        })
      );
      audiorelay-desktop-item = makeDesktopItem {
        name = "audiorelay auto connect wrapper";
        desktopName = "audiorelay auto connect wrapper";
        exec = "${lib.getExe audiorelay}";
      };
      aria2dl-desktop-item = makeDesktopItem {
        name = "aria2dl magnet handler";
        desktopName = "aria2dl magnet handler";
        exec = "${lib.getExe aria2dl} %U";
        mimeTypes = [ "x-scheme-handler/magnet" ];
      };
      rename-torrents = writers.writePython3Bin "rename-torrents" {
        libraries = [ python3Packages.bencode-py ];
      } (builtins.readFile ./rename-torrents.py);
    in
    [
      aria2dl
      aria2dl-desktop-item
      libnotify # aria2dl-notify
      tesseract # screenshot
      imagemagick # screenshot
      audiorelay
      audiorelay-desktop-item
      inputs.audiorelay.packages.${system}.audio-relay
      rename-torrents
    ]
    ++ lib.forEach [
      "0x0"
      "micmute"
      "aria2dl-notify"
      "search"
      "rebuild"
      "screenshot"
    ] (x: writeShellScriptBin "${x}" (builtins.readFile ./${x}.sh))
    ++
      lib.forEach
        [
          "nyaasi"
          "1337x"
        ]
        (
          x:
          writers.writePython3Bin "${x}" { libraries = [ python3Packages.papis-python-rofi ]; }
            (substituteAll {
              src = ./${x}.py;
              videoPath = "/home/wera/videos";
            })
        );
}
