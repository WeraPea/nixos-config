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
  pname = "equalizer";
  inherit version;

  src = fetchFromGitHub {
    owner = "occivink";
    repo = "mpv-image-viewer";
    rev = "efc8214";
    hash = "sha256-H7uBwrIb5uNEr3m+rHED/hO2CHypGu7hbcRpC30am2Q=";
  };
  dontBuild = true;

  installPhase = ''
    install -Dm644 scripts/equalizer.lua $out/share/mpv/scripts/equalizer.lua
  '';

  passthru.scriptName = "equalizer.lua";

  meta = with lib; {
    description = "Adds bars for brightness, contrast, gamma, saturation, hue.";
    homepage = "https://github.com/torque/mpv-image-viewer";
    platforms = platforms.all;
    license = licenses.unlicense;
  };
}
