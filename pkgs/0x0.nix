{
  lib,
  writeShellScriptBin,
  curl,
  wl-clipboard,
}:
writeShellScriptBin "0x0" ''
  ${lib.getExe curl} -F "file=@$1" 0x0.st | ${lib.getExe' wl-clipboard "wl-copy"}
''
