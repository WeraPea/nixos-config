{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  ...
}:
{
  home.packages =
    with pkgs;
    let
      ifElse =
        p: yes: no:
        if p then yes else no;
      aria2dl = writeShellScriptBin "aria2dl" (builtins.readFile ./aria2dl.sh);
      audiorelay = writeShellScriptBin "audiorelay-wrapper" (
        builtins.readFile (
          replaceVars ./audiorelay.sh {
            xdotool = "${lib.getExe xdotool}";
            xvfb = "${lib.getExe' xorg.xvfb "Xvfb"}";
            pactl = ''${lib.getExe' pulseaudio "pactl"}'';
          }
        )
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
      rename-torrents
    ]
    ++
      ifElse osConfig.graphics.enable
        [
          aria2dl-desktop-item
          imagemagick # screenshot
          libnotify # aria2dl-notify
          tesseract # screenshot
        ]
        [ ]
    ++
      ifElse config.desktopPackages.enable
        [
          audiorelay
          audiorelay-desktop-item
          inputs.audiorelay.packages.${system}.audio-relay
        ]
        [ ]
    ++ lib.forEach (
      [
        "0x0"
        "rebuild"
      ]
      ++
        ifElse osConfig.graphics.enable
          [
            "aria2dl-notify"
            "screenshot"
            "search"
            "vrlink"
            "adbconnect"
          ]
          [ ]
      ++
        ifElse config.desktopPackages.enable
          [
            "vrlink"
          ]
          [ ]
    ) (x: writeShellScriptBin "${x}" (builtins.readFile ./${x}.sh))
    ++
      lib.forEach
        (ifElse osConfig.graphics.enable
          [
            "1337x"
            "nyaasi"
          ]
          [ ]
        )
        (
          x:
          writers.writePython3Bin "${x}" { libraries = [ python3Packages.papis-python-rofi ]; } (
            replaceVars ./${x}.py {
              videoPath = "/home/wera/videos";
            }
          )
        );
}
