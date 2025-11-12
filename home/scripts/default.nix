# TODO: fix this mess
{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  outputs,
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
          grim # screenshot
          imagemagick # screenshot
          libnotify # aria2dl-notify
          slurp # screenshot
          tesseract # screenshot
          outputs.packages.${stdenv.hostPlatform.system}.manga-ocr-from-file # screenshot
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
