{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  aria2,
  kitty,
  libnotify,
}:
let
  aria2dl-notify = writeShellScriptBin "aria2dl-notify" ''
    ${lib.getExe libnotify} "Download Complete!"
  '';
  aria2dl = writeShellScriptBin "aria2dl" ''
    ${lib.getExe kitty} ${lib.getExe aria2} "$@" --bt-save-metadata=true --bt-prioritize-piece=head --on-bt-download-complete=${lib.getExe aria2dl-notify} --dir ~/Downloads/aria2/ --bt-max-peers=500 --bt-enable-lpd=true
  '';
  aria2dl-desktop-item = makeDesktopItem {
    name = "aria2dl magnet handler";
    desktopName = "aria2dl magnet handler";
    exec = "${lib.getExe aria2dl} %U";
    mimeTypes = [ "x-scheme-handler/magnet" ];
  };
in
symlinkJoin {
  name = "aria2dl";
  paths = [
    aria2dl
    aria2dl-desktop-item
  ];
}
