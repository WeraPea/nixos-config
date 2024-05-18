{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  luaPackages,
}:
let
  version = "0-unstable-2023-03-03";
in
stdenvNoCC.mkDerivation {
  pname = "freeze-window";
  inherit version;

  src = fetchFromGitHub {
    owner = "occivink";
    repo = "mpv-image-viewer";
    rev = "efc8214";
    hash = "sha256-H7uBwrIb5uNEr3m+rHED/hO2CHypGu7hbcRpC30am2Q=";
  };
  dontBuild = true;

  installPhase = ''
    install -Dm644 scripts/freeze-window.lua $out/share/mpv/scripts/freeze-window.lua
  '';

  passthru.scriptName = "freeze-window.lua";

  meta = with lib; {
    description = "By default, mpv automatically resizes the window when the current file changes to fit its size. This script freezes the window so that this does not happen. There is no configuration.";
    homepage = "https://github.com/torque/mpv-image-viewer";
    platforms = platforms.all;
    license = licenses.unlicense;
    maintainers = with maintainers; [ WeraPea ];
  };
}
