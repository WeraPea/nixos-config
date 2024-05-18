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
  pname = "status-line";
  inherit version;

  src = fetchFromGitHub {
    owner = "occivink";
    repo = "mpv-image-viewer";
    rev = "efc8214";
    hash = "sha256-H7uBwrIb5uNEr3m+rHED/hO2CHypGu7hbcRpC30am2Q=";
  };
  dontBuild = true;

  installPhase = ''
    install -Dm644 scripts/status-line.lua $out/share/mpv/scripts/status-line.lua
  '';

  passthru.scriptName = "status-line.lua";

  meta = with lib; {
    description = "Adds a status line that can show different properties in the corner of the window.";
    homepage = "https://github.com/torque/mpv-image-viewer";
    platforms = platforms.all;
    license = licenses.unlicense;
    maintainers = with maintainers; [ WeraPea ];
  };
}
