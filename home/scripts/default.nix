{pkgs, ...}: {
  home.packages = with pkgs;
    [
      (writers.writePython3Bin "nyaasi" {libraries = [pkgs.python3Packages.papis-python-rofi];} (substituteAll {
        src = ./nyaasi.py;
        videoPath = "/home/wera/videos";
      }))
    ]
    ++ lib.forEach ["0x0" "micmute" "aria2dl" "aria2dl-notify" "cliphist-rofi-img" "search" "rebuild"] (x: writeShellScriptBin "${x}" (builtins.readFile ./${x}.sh));
}
