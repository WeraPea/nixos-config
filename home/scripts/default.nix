{pkgs, ...}: {
  home.packages = with pkgs;
    [
      (writers.writePython3Bin "nyaasi" {libraries = [pkgs.python3Packages.papis-python-rofi];} (builtins.readFile ./nyaasi.py))
    ]
    ++ lib.forEach ["0x0" "aria2dl" "aria2dl-notify" "cliphist-rofi-img" "search" "rebuild"] (x: writeShellScriptBin "${x}" (builtins.readFile ./${x}.sh));
}
