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
      audiorelay-wrapper = runCommand "audiorelay-wrapper" { } ''
        mkdir -p $out/bin
        substitute ${./audiorelay.sh} $out/bin/audiorelay-wrapper \
          --replace '@xdotool@' '${lib.getExe xdotool}' \
          --replace '@xvfb@' '${lib.getExe' xorg.xvfb "Xvfb"}' \
          --replace '@pactl@' '${lib.getExe' pulseaudio "pactl"}'
        chmod +x $out/bin/audiorelay-wrapper
      '';
      audiorelay-desktop-item = makeDesktopItem {
        name = "audiorelay auto connect wrapper";
        desktopName = "audiorelay auto connect wrapper";
        exec = "${lib.getExe' audiorelay-wrapper "audiorelay-wrapper"}";
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
          audiorelay-wrapper
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
