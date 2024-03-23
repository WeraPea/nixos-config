{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; let
    aria2dl = writeShellScriptBin "aria2dl" (builtins.readFile ./aria2dl.sh);
    aria2dl-desktop-item = makeDesktopItem {
      name = "aria2dl magnet handler";
      desktopName = "aria2dl magnet handler";
      exec = "${lib.getExe aria2dl} %U";
      mimeTypes = ["x-scheme-handler/magnet"];
    };
    nyaasi = writers.writePython3Bin "nyaasi" {libraries = [pkgs.python3Packages.papis-python-rofi];} (substituteAll {
      src = ./nyaasi.py;
      videoPath = "/home/wera/videos";
    });
  in
    [
      aria2dl
      aria2dl-desktop-item
      nyaasi
      libnotify
    ]
    ++ lib.forEach ["0x0" "micmute" "aria2dl-notify" "cliphist-rofi-img" "search" "rebuild"] (x: writeShellScriptBin "${x}" (builtins.readFile ./${x}.sh));
}
