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
  pname = "detect-image";
  inherit version;

  src = fetchFromGitHub {
    owner = "occivink";
    repo = "mpv-image-viewer";
    rev = "efc8214";
    hash = "sha256-H7uBwrIb5uNEr3m+rHED/hO2CHypGu7hbcRpC30am2Q=";
  };
  dontBuild = true;

  installPhase = ''
    install -Dm644 scripts/detect-image.lua $out/share/mpv/scripts/detect-image.lua
  '';

  passthru.scriptName = "detect-image.lua";

  meta = with lib; {
    description = "Allows you to run specific commands when images are being displayed.";
    homepage = "https://github.com/torque/mpv-image-viewer";
    platforms = platforms.all;
    license = licenses.unlicense;
    maintainers = with maintainers; [ WeraPea ];
  };
}
